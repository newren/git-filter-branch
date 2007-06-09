#!/bin/sh

test_description='git-filter-branch'
. ./test-lib.sh

make_commit () {
	lower=$(echo $1 | tr A-Z a-z)
	echo $lower > $lower
	git add $lower
	test_tick
	git commit -m $1
	git tag $1
}

test_expect_success 'setup' '
	make_commit A
	make_commit B
	git checkout -b branch B
	make_commit D
	make_commit E
	git checkout master
	make_commit C
	git checkout branch
	git merge C
	git tag F
	make_commit G
	make_commit H
'

H=$(git-rev-parse H)

test_expect_success 'rewrite identically' '
	git-filter-branch H2
'

test_expect_success 'result is really identical' '
	test $H = $(git-rev-parse H2)
'

test_expect_success 'rewrite, renaming a specific file' '
	git-filter-branch --tree-filter "mv d doh || :" H3
'

test_expect_success 'test that the file was renamed' '
	test d = $(git show H3:doh)
'

git tag oldD H3~4
test_expect_success 'rewrite one branch, keeping a side branch' '
	git-filter-branch --tree-filter "mv b boh || :" modD D..oldD
'

test_expect_success 'common ancestor is still common (unchanged)' '
	test "$(git-merge-base modD D)" = "$(git-rev-parse B)"
'

test_expect_success 'filter subdirectory only' '
	mkdir subdir &&
	touch subdir/new &&
	git add subdir/new &&
	test_tick &&
	git commit -m "subdir" &&
	echo H > a &&
	test_tick &&
	git commit -m "not subdir" a &&
	echo A > subdir/new &&
	test_tick &&
	git commit -m "again subdir" subdir/new &&
	git rm a &&
	test_tick &&
	git commit -m "again not subdir" &&
	git-filter-branch --subdirectory-filter subdir sub
'

test_expect_success 'subdirectory filter result looks okay' '
	test 2 = $(git-rev-list sub | wc -l) &&
	git show sub:new &&
	! git show sub:subdir
'

test_done
