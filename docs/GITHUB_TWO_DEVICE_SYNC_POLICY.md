# سياسة مزامنة Pal Eyes بين جهازين عبر GitHub

```text
AUTHORITATIVE_REMOTE=https://github.com/firasfanon/Pal_Eyes
AUTHORITATIVE_BRANCH_AFTER_PROMOTION=main
DIRECT_DEVELOPMENT_ON_MAIN=FORBIDDEN
ONE_TASK_ONE_BRANCH=TRUE
PULL_MODE=FAST_FORWARD_ONLY
FORCE_PUSH_TO_MAIN=FORBIDDEN
```

## حالة المستودع عند إعادة البناء

```text
REMOTE_MAIN=c67ff5e28205aac57ff28e8b8120c3bac5de4488
REMOTE_VERSION=8.0.1+27
CANDIDATE_VERSION=9.0.1+30
REMOTE_UPDATE_REQUIRED=TRUE
CONNECTOR_WRITE_GATE=BLOCKED_403
```

## التسلسل الملزم

1. شغّل finalizer في فرع مزامنة جديد.
2. ارفع الفرع دون Force.
3. افتح Pull Request إلى `main`.
4. لا يستخدم الجهاز الثاني النسخة بوصفها authoritative قبل دمج PR.
5. بعد الدمج:
   `git fetch --prune` ثم `git switch main`
   ثم `git pull --ff-only`.
6. يبدأ كل تطوير لاحق من فرع مستقل.
