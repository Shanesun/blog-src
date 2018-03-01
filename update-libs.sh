#!/bin/bash

git subtree pull --prefix=themes/next next master
git subtree pull --prefix=themes/next/sources/lib/fancybox fancybox master
git subtree pull --prefix=themes/next/sources/lib/pace pace master

