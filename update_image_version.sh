#!/bin/bash
imageVersion="danle360/mongodb-springboot-app:v$BUILD_NUMBER"
sed -i "s#image_version_update#${imageVersion}#g" springboot_manifest.yml
cat springboot_manifest.yml |grep  'danle'
