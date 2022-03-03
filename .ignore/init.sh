#!/usr/bin/env bash

timestamp(){
    date
}

echo "$(timestamp) Locating required resources..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $DIR

IDTOKEN=null
GATEWAY_ENDPOINT=null
CLIENT_ID=null
HEADER1='X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth'
HEADER2='Content-Type: application/x-amz-json-1.1'

if [ $STAGE == "prod" ]
then
    echo "$(timestamp) Using Prod Artifact..."
    GATEWAY_ENDPOINT='https://slygfw4sw7.execute-api.ap-south-1.amazonaws.com/Prod/get-signed-url'
    CLIENT_ID=7r012t0noqgjoaarjuc1u21v85
elif [ $STAGE == "test" ]
then
    echo "$(timestamp) Using Test Artifact..."
    GATEWAY_ENDPOINT='https://ivcgd3sjsk.execute-api.ap-south-1.amazonaws.com/Prod/get-signed-url'
    CLIENT_ID=5jrqkesh41t56ragneqln5ilkl
else
    echo "$(timestamp) Using Dev Artifact..."
    GATEWAY_ENDPOINT='https://piqcbc19ya.execute-api.ap-south-1.amazonaws.com/Prod/get-signed-url'
    CLIENT_ID=233o8b28j9k1423sh0vgujvn3c
fi


getIdToken() {
  read -p "Enter your email : " USER_NAME
  read -s -p "Enter your password : " PASSWORD
  BODY='{"ClientId": "'"$CLIENT_ID"'","AuthParameters": {"USERNAME": "'"$USER_NAME"'","PASSWORD": "'"$PASSWORD"'"},"AuthFlow": "USER_PASSWORD_AUTH"}'
  IDTOKEN=`curl -s -XPOST -H "$HEADER1" -H "$HEADER2" -d "$BODY" 'https://cognito-idp.ap-south-1.amazonaws.com/' | jq -r .AuthenticationResult.IdToken`
  echo
}

echo "Please Enter your Details Below ...."
getIdToken

while [ $IDTOKEN == null ]; do
  echo -e "\e[1;31m------------Enter valid credentials...--------------------\e[0m"
  echo ""
  getIdToken
done

echo -e "\e[1;32m------------User Authenticated...--------------------\e[0m"
ARTIFACT_URL=`curl -H -s "Authorization: $IDTOKEN" $GATEWAY_ENDPOINT`


echo "Artifact url obtained....."
echo ""
echo -e "\e[1;34m $(timestamp) --------- Starting download of artifact ... --------------\e[0m"
curl  --output guru-shifu.tar.gz "$ARTIFACT_URL"
echo "$(timestamp) Artifact download complete."
echo "$(timestamp) Unzipping guru-shifu tarball..."
tar -xf guru-shifu.tar.gz
echo "$(timestamp) Unzip complete"
mkdir /workspace/guru-shifu-gitpod/m2-repository
printf '<settings>\n  <localRepository>/workspace/gitpod/m2-repository/</localRepository>\n</settings>\n' > /home/gitpod/.m2/settings.xml
echo "$(timestamp) Loading guru-shifu images..."
docker load -i guru-shifu-images.tar.gz
echo "$(timestamp) Guru-shifu images loaded successfully"
