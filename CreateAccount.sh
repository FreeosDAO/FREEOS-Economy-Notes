#!/bin/bash
#proton="/usr/local/bin/cleos -u https://api-testnet-proton.eosarabia.net:443"
proton="$(which cleos) -u https://api-testnet-proton.eosarabia.net:443"

echo "Enter Account name"
read acc

if ! [[ "${acc}" =~ [^a-z1-5$] || ${#acc} -lt 3 || ${#acc} -gt 12 ]]; then
  echo "Account Name: ${acc}"
else
  echo "ERROR: Account Name not Valid [Min length 3, Max 12 with 1-5 and a-z only. No space allowed.]"
  exit 1
fi

echo "Enter verification type: [e:d:v]"
read verify

if [ -z "$verify" ]
then
    verify="e"
fi

echo "Account: ${acc}, Verification type: $verify"

${proton} wallet create -n proton_${acc} --file ${acc}.psw
${proton} wallet unlock -n proton_${acc} --password `cat ${acc}.psw`
${proton} wallet create_key -n proton_${acc}
${proton} wallet create_key -n proton_${acc}
#${proton} wallet private_keys -n proton_${acc} --password `cat ${acc}.psw`
echo "Wallet Created:${acc}";cat ${acc}.psw;echo
${proton} wallet private_keys -n proton_${acc} --password `cat ${acc}.psw`

echo "Script will PAUSE Now. Create Account in Browser"
created=False
while [[ "$created" != "DONE" ]]
do
    echo "Have you created an account on Proton network?"
    echo "When Write 'DONE'"
    read created
    sleep 1
done


if [[ "$verify" == "d" || "$verify" == "v" ]]; then
    echo "Verifying the User"
    ${proton} wallet unlock -n proton_freeosconfig --password PW5KhwXSFB1gfDSTVP9eiiU8uRBXXG7DbdP2ooGFXiM68jTNatker
    ${proton} push action freeosconfig userverify "[\"${acc}\", \"metal.kyc\", true]" -p freeosconfig@active
    ${proton} get table freeosconfig freeosconfig usersinfo | grep ${acc}
fi

if [ "$verify" == "v" ]
then
    echo "Proceeding for ${acc} as KYC-VERIFIED"
    ${proton} push action freeosconfig addkyc "[\"${acc}\", \"metal.kyc\", \"trulioo:address,trulioo:lastname,trulioo:firstname,trulioo:birthdate\", 1604435610]" -p freeosconfig@active

fi

${proton} get table freeosconfig freeosconfig usersinfo | grep ${acc}

echo "Script complete!"
