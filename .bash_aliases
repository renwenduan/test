cbranch(){ git fetch origin && git checkout -b request/$1 origin/master ; }      

test_commit_ok(){ git st | grep -Ev "## "; if [ $? -eq 0 ] ; then echo "WARNING - File no commited"; return 1; fi; }

dev(){ test_commit_ok && git fetch origin && git checkout develop && git reset --hard origin/develop && git merge --no-ff request/$1 && git push origin develop && fab gearman.deploy ; echo -e "\n$1"; git checkout request/$1; }

inc(){ test_commit_ok && git fetch origin && git checkout incubator && git reset --hard origin/incubator && git merge --no-ff request/$1 && git push origin incubator && fab gearman.deploy; echo -e "\n$1"; }

rebase(){ test_commit_ok && git fetch origin && git checkout request/$1 && git rebase -i origin/integration; }

integration(){ test_commit_ok && git fetch --dry-run origin >~/fetch_gearman_log 2>&1 && grep -v "up to date" ~/fetch_gearman_log | grep "integration"; if [ $? -ne 0 ]; then git fetch origin && git checkout integration && git reset --hard origin/integration && git merge --no-ff request/$1 && git push origin integration; else echo -e "\n\n------------ ERROR ---------\n\nWARNING branch integration is modified => PLEASE   rebase $1   before   integration $1   \n\n"; fi; }

push() { git push origin request/${1}:u/$(whoami)/request/$1; }

purge_repo(){ git fetch origin && git remote prune origin && git fsck --full && git checkout incubator && git reset --hard origin/incubator && git checkout develop && git reset --hard origin/develop && git checkout master && git reset --hard origin/master; }

weekly_integration_prepare_tmp(){ git fetch -p && git checkout master && git rebase origin/integration && fab git.tag.master:signed=no && git checkout incubator && git reset --hard master && git checkout develop && git reset --hard master && git checkout incubator; }

weekly_integration_prepare(){ git fetch -p && git checkout master && git rebase origin/integration && fab git.tag.master:signed=no && git checkout incubator && git reset --hard master && git merge --no-ff $(git branch -r --list '*/u/*') && git checkout develop && git reset --hard master && git checkout master; }

weekly_integration_push(){ git checkout master && git push --tags origin master +incubator +develop && fab gearman.deploy:master=yes; }

check_rebase_integrate() { branch="$(echo $1 | cut -d/ -f4)_$(echo $1 | cut -d/ -f2)" ; git fetch origin && git checkout -b request/$branch origin/$1 && tig status && rebase $branch && integration $branch && git branch -D request/$branch && git lg ; }

url_proc_diff() { echo -e "GET hosts\nColumns: name notes_url_expanded" | nc monsat-master.edc.eu.corp 6557 > ~/proc/hosts_wi_links_master.txt &&  echo -e "GET hosts\nColumns: name notes_url_expanded" | nc monsat-develop.eas.ww.corp 6557 > ~/proc/hosts_wi_links_develop.txt && join ~/proc/hosts_wi_links_master.txt ~/proc/hosts_wi_links_develop.txt -t';' -1 1 -2 1 >~/proc/hosts_wi_links.csv; xdg-open ~/proc/hosts_wi_links.csv ; }

url_proc_srvc_diff() { echo -e "GET services\nColumns: host_name description notes_url_expanded" | nc monsat-master.edc.eu.corp 6557 > ~/proc/services_wi_links_master.txt &&  echo -e "GET services\nColumns: host_name description notes_url_expanded" | nc monsat-develop.eas.ww.corp 6557 > ~/proc/services_wi_links_develop.txt && sed -r -i -e 's/^(.*);(.*);/\1 \2;/' ~/proc/services_wi_links_*.txt && join ~/proc/services_wi_links_master.txt ~/proc/services_wi_links_develop.txt -t';' -1 1 -2 1 >~/proc/services_wi_links.csv; xdg-open ~/proc/services_wi_links.csv ; }

after_weekly_integration() { git fp && git checkout incubator && git reset --hard origin/master && fab merge.into_incubator && weekly_reset_dev && incubator_push; }

incubator_push() { git push origin +incubator +develop && fab gearman.deploy; }

merge_into_incub() { git checkout incubator && git merge --no-ff $1 || git mergetool --tools=meld && git st; }

weekly_reset_dev() { git checkout develop && git reset --hard incubator; }

# test integration
test_integration() { git fetch -p && git checkout develop && git reset --hard origin/integration && git push origin +develop && fab gearman.deploy; }

workstation() { ssh asadcmonws02.cn.corp; }
