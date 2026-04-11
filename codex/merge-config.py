#!/usr/bin/env python3
"""codex/config.toml に書いたキーとテーブルだけを ~/.codex/config.toml に上書きする。

使い方: merge-config.py <dotfiles の config.toml> <~/.codex/config.toml>

- トップレベルのキーは同じキーの行を置き換え、無ければ先頭のキー群の末尾に足す。
- テーブル ([mcp_servers.context7] など) は同じ見出しのブロックを丸ごと置き換え、無ければ末尾に足す。
- それ以外 (アプリが書くプラグイン・プロジェクト一覧など) には触らない。
- 書き込み前に元ファイルを .bak-<日時> に退避し、書き込み後に値が反映されたかを tomllib で検証する。
"""
import re
import shutil
import sys
import time
import tomllib

HEADER = re.compile(r"^\s*\[[^\[\]]+\]\s*$")
KEY = re.compile(r"^\s*([A-Za-z0-9_.\"-]+)\s*=")


def split_blocks(text):
    """先頭のキー群 (行のリスト) と、[見出し] ごとのブロック {見出し: 行のリスト} に分ける。"""
    preamble, tables, order, current = [], {}, [], None
    for line in text.splitlines():
        if HEADER.match(line):
            current = line.strip()
            tables[current] = [line]
            order.append(current)
        elif current is None:
            preamble.append(line)
        else:
            tables[current].append(line)
    return preamble, tables, order


def strip_comments(lines):
    return [l for l in lines if l.strip() and not l.lstrip().startswith("#")]


def main(src_path, dst_path):
    src_text = open(src_path, encoding="utf-8").read()
    src = tomllib.loads(src_text)  # 構文エラーならここで止める
    dst_text = open(dst_path, encoding="utf-8").read()
    tomllib.loads(dst_text)

    s_pre, s_tables, s_order = split_blocks(src_text)
    d_pre, d_tables, d_order = split_blocks(dst_text)

    for line in strip_comments(s_pre):
        key = KEY.match(line).group(1)
        idx = next((i for i, l in enumerate(d_pre) if (m := KEY.match(l)) and m.group(1) == key), None)
        if idx is None:
            # 末尾の空行の前に足す
            pos = len(d_pre)
            while pos > 0 and not d_pre[pos - 1].strip():
                pos -= 1
            d_pre.insert(pos, line)
        else:
            d_pre[idx] = line

    for header in s_order:
        block = [s_tables[header][0]] + strip_comments(s_tables[header][1:]) + [""]
        if header in d_tables:
            d_tables[header] = block
        else:
            d_tables[header] = block
            d_order.append(header)

    def trim(lines):
        return "\n".join(lines).strip("\n")

    out = "\n\n".join([trim(d_pre)] + [trim(d_tables[h]) for h in d_order]) + "\n"

    merged = tomllib.loads(out)
    original = tomllib.loads(dst_text)

    # dotfiles に書いていない部分 (アプリが書く設定) が 1 つも変わっていないことを確かめる
    def drop(data, managed):
        out = {}
        for k, v in data.items():
            if k in managed and not isinstance(managed[k], dict):
                continue
            if isinstance(v, dict) and isinstance(managed.get(k), dict):
                v = drop(v, managed[k])
                if not v:  # 管理しているテーブルだけが入っていた入れ物は比較から外す
                    continue
            out[k] = v
        return out

    if drop(merged, src) != drop(original, src):
        sys.exit("merge failed: 管理外の設定が変わってしまうので書き込まない")

    def check(want, got, path=""):
        for k, v in want.items():
            if isinstance(v, dict):
                check(v, got.get(k, {}), f"{path}{k}.")
            elif got.get(k) != v:
                sys.exit(f"merge failed: {path}{k} が反映されていない")

    check(src, merged)

    if out == dst_text:
        print("  = 変更なし")
        return
    backup = f"{dst_path}.bak-{time.strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(dst_path, backup)
    with open(dst_path, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"  + 反映した (退避: {backup})")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
