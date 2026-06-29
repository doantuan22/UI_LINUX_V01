# Protocol 04 — Test Execution Strategy

## Mục tiêu

Chọn và chạy đúng loại test cho từng loại project, không bỏ sót lỗi build/runtime/UI/performance.

## Nhận diện project

### Node.js / Web / Electron

Dấu hiệu:

- `package.json`
- `vite.config.*`, `webpack.config.*`, `electron.*`
- `src/`, `public/`, `dist/`

Lệnh kiểm tra thường dùng:

```bash
npm run lint --if-present
npm run typecheck --if-present
npm test --if-present
npm run build --if-present
```

Nếu dùng pnpm/yarn/bun thì dùng đúng package manager theo lockfile:

- `pnpm-lock.yaml` → pnpm.
- `yarn.lock` → yarn.
- `bun.lockb` hoặc `bun.lock` → bun.
- `package-lock.json` → npm.

### Python

Dấu hiệu:

- `requirements.txt`
- `pyproject.toml`
- `pytest.ini`
- `src/`, `tests/`

Lệnh kiểm tra thường dùng:

```bash
python --version
python -m pytest -q
python -m compileall .
```

Nếu có tool:

```bash
ruff check .
mypy .
```

### C/C++

Dấu hiệu:

- `CMakeLists.txt`
- `Makefile`
- `src/*.cpp`, `include/`

Lệnh kiểm tra thường dùng:

```bash
cmake --build build
ctest --test-dir build --output-on-failure
```

### Rust

```bash
cargo check
cargo test
cargo clippy -- -D warnings
cargo fmt --check
```

## Thứ tự chạy test

1. `install check`: dependency có đủ không.
2. `static check`: lint/type/compile.
3. `unit test`: test nhỏ.
4. `integration test`: test ghép module.
5. `build`: đảm bảo đóng gói được.
6. `smoke test`: chạy app thật.
7. `manual UI test`: kiểm tra hiển thị/tương tác.
8. `performance sanity`: CPU/RAM/log.
9. `regression test`: test lại chức năng cũ.

## Quy tắc khi test fail

Khi test fail, không sửa ngay. Phải ghi:

```text
Failed command:
Exit code:
First failing test:
Error message:
Suspected area:
Next verification:
```

## Khi project không có test

AI coding phải tạo test tối thiểu hoặc checklist manual:

- Smoke test khởi động app.
- Test chức năng chính.
- Test input sai.
- Test log lỗi.
- Test build nếu có.

Không được kết luận “ổn” chỉ vì app mở được.
