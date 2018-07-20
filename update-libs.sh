#!/bin/bash

git subtree pull --prefix=themes/next next master
git subtree pull --prefix=themes/next/source/lib/fancybox fancybox master
git subtree pull --prefix=themes/next/source/lib/pace pace master
git subtree pull --prefix=themes/next/source/lib/pangu pangu master

