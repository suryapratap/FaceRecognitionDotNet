#!/bin/bash

VERSION=$1
OS='osx'
OSVERSION=$4

CURDIR=${pwd}
FRDNROOT=`dirname $(pwd)`
WORK=${FRDNROOT}/work

packages=(
    "FaceRecognitionDotNet"
    "FaceRecognitionDotNet.MKL"
    #"cuda"
)

for package in "${packages[@]}" ; do
    PACKAGE=$package    
    TESTDIR=${FRDNROOT}/nuget/artifacts/test/${PACKAGE}.${VERSION}/${OS}
    
    mkdir -p ${WORK}
    mkdir -p ${TESTDIR}    
    
    cp -Rf ${FRDNROOT}/test/FaceRecognitionDotNet.Tests ${WORK}
    cd ${WORK}/FaceRecognitionDotNet.Tests
  
    # delete local project reference
    dotnet remove reference ../../DlibDotNet/src/DlibDotNet\DlibDotNet.csproj > /dev/null 2>&1
    dotnet remove reference ../../src/FaceRecognitionDotNet/FaceRecognitionDotNet.csproj > /dev/null 2>&1
    
    # restore package from local nuget pacakge
    # And drop stdout message
    dotnet add package $PACKAGE -v $VERSION --source ${FRDNROOT}/nuget/ > /dev/null 2>&1
    
    dotnet test -c Release -r ${TESTDIR} --logger trx

    # move to current
    cd $CURDIR

    # to make sure, delete
    if [ -e ${WORK} ]; then
       rm -Rf ${WORK}
    fi
done