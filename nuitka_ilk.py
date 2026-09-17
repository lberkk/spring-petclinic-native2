import sys
import subprocess
from pathlib import Path

def run(cmd, cwd=None):
    subprocess.run(cmd, cwd=cwd)
def parse_requirements_txt(requirements_path: Path) -> list[str]:
    lines = requirements_path.read_text(encoding="utf-8").splitlines()
    deps = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        deps.append(line)
    return deps
def install_dependencies_if_needed(project_dir: Path, entry_py: Path):
    req = project_dir / "requirements.txt"
    if req.exists():
        deps = parse_requirements_txt(req)
        if deps:
            run([sys.executable, "-m", "pip", "install", "-r", str(req)], cwd=str(project_dir))
        return
def main():
    project_dir = Path.cwd()
    entry_py = Path(sys.argv[1])
    if not entry_py.is_absolute():
        entry_py = project_dir / entry_py
    entry_py = entry_py.resolve()
    install_dependencies_if_needed(project_dir, entry_py)
    cmd = [sys.executable, "-m", "nuitka", str(entry_py)]
    if "--onefile" in sys.argv:
        cmd.append("--onefile")
    else:
        cmd.append("--standalone")
    run(cmd, cwd=str(project_dir))

if __name__ == "__main__":
    main()


