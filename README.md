# bootstrap

One command installs a working set of AI-agent skills on a new machine.
Everything here is either a public upstream skill (pinned by commit SHA) or a
small bundled skill in [`skills/`](skills/).

## Use it

```bash
git clone https://github.com/demetre19/bootstrap.git
cd bootstrap
./install.sh            # asks which profile you want
```

Two profiles:

- **`user`** — debugging, security scans, UI/UX quality, ponytail scope
  discipline. 33 skills, no credentials needed.
- **`technical`** — everything in `user` plus Cloudflare, Supabase, GitHub
  workflow, DataForSEO, and `last30days`. 45 skills.

Details, source table, and install-directory detection order are in
[BOOTSTRAP.md](BOOTSTRAP.md).
