#!/usr/bin/env bash
# UCI Machine Learning Repository "Bike Sharing Dataset" を取得し、SHA-256 で同一性を検証する。
# 出力先: このスクリプトと同じディレクトリの raw/ 配下（hour.csv / day.csv / Readme.txt）
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
raw_dir="${here}/raw"
url="https://archive.ics.uci.edu/static/public/275/bike+sharing+dataset.zip"
zip_path="${raw_dir}/bike-sharing-dataset.zip"

expected_zip="b70182d0d0508e9abbb79306ce5c0cec34869000f8220175ac83d11dbe845401"
expected_hour="e03de4ee4ef4dc376ac6e04bf829673c6269e8eba5c60fa121640fa2f829504f"
expected_day="a6bcf826782d3c0fbfdcbeead17cd0884185a0dafe8ff10cd48a874ee7ba18be"

sha256() { shasum -a 256 "$1" | awk '{print $1}'; }

verify() {
  local path="$1" expected="$2" actual
  actual="$(sha256 "$path")"
  if [[ "$actual" != "$expected" ]]; then
    echo "SHA-256 mismatch: $path" >&2
    echo "  expected: $expected" >&2
    echo "  actual:   $actual" >&2
    exit 1
  fi
  echo "ok  $(basename "$path")  $actual"
}

mkdir -p "$raw_dir"
curl -fsSL -o "$zip_path" "$url"
verify "$zip_path" "$expected_zip"
unzip -oq "$zip_path" -d "$raw_dir"
rm -f "$zip_path"
verify "${raw_dir}/hour.csv" "$expected_hour"
verify "${raw_dir}/day.csv" "$expected_day"
echo "done: ${raw_dir}"
