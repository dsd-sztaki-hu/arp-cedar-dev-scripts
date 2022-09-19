#!/usr/bin/env -S bash -e

# Remember where we started
CURRDIR=`dirname "$0"`
CURRDIR=`realpath $CURRDIR`

source ./common.sh

cd ${CEDAR_HOME}

if [[ -d "${CEDAR_HOME}/CEDAR_CA" ]]; then
  echo "++++ Checking whether ca.crt is created for CN=$CEDAR_HOST"
  if [[ -f "CEDAR_CA/ca.crt" && ! -z `openssl x509 -text -noout -in CEDAR_CA/ca.crt | grep "CN = $CEDAR_HOST"` ]]; then
    echo "++++ ca.crt is already created for CN=$CEDAR_HOST. Skipping."
    exit 0
  fi
fi

cd $CURRDIR



#
#
# All this is based on https://metadatacenter.readthedocs.io/en/latest/install-developer/cert-self-signed/
#
#
echo "++++ Generating openssl configs in ${CEDAR_HOME}/CEDAR_CA"
rm -rf  ${CEDAR_HOME}/CEDAR_CA
mkdir ${CEDAR_HOME}/CEDAR_CA

# based on /usr/local/etc/openssl@1.1/openssl.cnf and https://metadatacenter.readthedocs.io/en/latest/install-developer/cert-self-signed/
cat > ${CEDAR_HOME}/CEDAR_CA/openssl-ca.cnf << 'EOF'
#
# OpenSSL example configuration file.
# This is mostly being used for generation of certificate requests.
#

# This definition stops the following lines choking if HOME isn't
# defined.
HOME			= .
#RANDFILE		= $ENV::HOME/.rnd
CEDAR_HOME = $ENV::CEDAR_HOME
CEDAR_HOST = $ENV::CEDAR_HOST

# Extra OBJECT IDENTIFIER info:
#oid_file		= $ENV::HOME/.oid
oid_section		= new_oids

# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
# extensions		=
# (Alternatively, use a configuration file that has only
# X.509v3 extensions in its main [= default] section.)

[ new_oids ]

# We can add new OIDs in here for use by 'ca', 'req' and 'ts'.
# Add a simple OID like this:
# testoid1=1.2.3.4
# Or use config file substitution like this:
# testoid2=${testoid1}.5.6

# Policies used by the TSA examples.
tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7

####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

#dir		= ./demoCA		# Where everything is kept
dir = $CEDAR_HOME/CEDAR_CA  # Where everything is kept
default_days = 36500                   # how long to certify for
default_md  = sha256                # use public key default MD

certs		= $dir/certs		# Where the issued certs are kept
crl_dir		= $dir/crl		# Where the issued crl are kept
database	= $dir/index.txt	# database index file.
#unique_subject	= no			# Set to 'no' to allow creation of
					# several certs with same subject.
new_certs_dir	= $dir/newcerts		# default place for new certs.

certificate	= $dir/cacert.pem 	# The CA certificate
serial		= $dir/serial 		# The current serial number
crlnumber	= $dir/crlnumber	# the current crl number
					# must be commented out to leave a V1 CRL
crl		= $dir/crl.pem 		# The current CRL
private_key	= $dir/private/cakey.pem# The private key
RANDFILE	= $dir/private/.rand	# private random number file

x509_extensions	= usr_cert		# The extensions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt 	= ca_default		# Subject Name options
cert_opt 	= ca_default		# Certificate field options

# Extension copying option: use with caution.
# copy_extensions = copy

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crlnumber must also be commented out to leave a V1 CRL.
# crl_extensions	= crl_ext

default_days	= 36500			# how long to certify for
default_crl_days= 30			# how long before next CRL
default_md	= sha256		# use public key default MD
preserve	= no			# keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy		= policy_match

# For the CA policy
[ policy_match ]
countryName		= match
stateOrProvinceName	= match
organizationName	= match
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional

# For the 'anything' policy
# At this point in time, you must list all acceptable 'object'
# types.
[ policy_anything ]
countryName		= optional
stateOrProvinceName	= optional
localityName		= optional
organizationName	= optional
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional

####################################################################
[ req ]
default_bits		= 2048
default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
attributes		= req_attributes
x509_extensions	= v3_ca	# The extensions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix	 : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

# req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= HU
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Hungary

localityName			= Locality Name (eg, city)
localityName_default    = Budapest

0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= SZTAKI

# we can do this but it is not needed normally :-)
#1.organizationName		= Second Organization Name (eg, company)
#1.organizationName_default	= World Wide Web Pty Ltd

organizationalUnitName		= Organizational Unit Name (eg, section)
#organizationalUnitName_default	= DSD

commonName			= Common Name (e.g. server FQDN or YOUR name)
commonName_max			= 64
commonName_default      = $CEDAR_HOST

emailAddress			= Email Address
emailAddress_max		= 64
emailAddress_default    = arp@sztaki.hu

# SET-ex3			= SET extension number 3

[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20

unstructuredName		= An optional company name

[ usr_cert ]

# These extensions are added when 'ca' signs a request.

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This is required for TSA certificates.
# extendedKeyUsage = critical,timeStamping

[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]


# Extensions for a typical CA


# PKIX recommendation.

subjectKeyIdentifier=hash

authorityKeyIdentifier=keyid:always,issuer

basicConstraints = critical,CA:true

# Key usage: this is typical for a CA certificate. However since it will
# prevent it being used as an test self-signed certificate it is best
# left out by default.
# keyUsage = cRLSign, keyCertSign

# Some might want this also
# nsCertType = sslCA, emailCA

# Include email address in subject alt name: another PKIX recommendation
# subjectAltName=email:copy
# Copy issuer details
# issuerAltName=issuer:copy

# DER hex encoding of an extension: beware experts only!
# obj=DER:02:03
# Where 'obj' is a standard or added object
# You can even override a supported extension:
# basicConstraints= critical, DER:30:03:01:01:FF

[ crl_ext ]

# CRL extensions.
# Only issuerAltName and authorityKeyIdentifier make any sense in a CRL.

# issuerAltName=issuer:copy
authorityKeyIdentifier=keyid:always

[ proxy_cert_ext ]
# These extensions should be added when creating a proxy certificate

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This really needs to be in place for it to be a proxy certificate.
proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

####################################################################
[ tsa ]

default_tsa = tsa_config1	# the default TSA section

[ tsa_config1 ]

# These are used by the TSA reply generation only.
#dir		= ./demoCA		# TSA root directory
dir = $CEDAR_HOME/CEDAR_CA  # Where everything is kept
serial		= $dir/tsaserial	# The current serial number (mandatory)
crypto_device	= builtin		# OpenSSL engine to use for signing
signer_cert	= $dir/tsacert.pem 	# The TSA signing certificate
					# (optional)
certs		= $dir/cacert.pem	# Certificate chain to include in reply
					# (optional)
signer_key	= $dir/private/tsakey.pem # The TSA private key (optional)
signer_digest  = sha256			# Signing digest to use. (Optional)
default_policy	= tsa_policy1		# Policy if request did not specify it
					# (optional)
other_policies	= tsa_policy2, tsa_policy3	# acceptable policies (optional)
digests     = sha1, sha256, sha384, sha512  # Acceptable message digests (mandatory)
accuracy	= secs:1, millisecs:500, microsecs:100	# (optional)
clock_precision_digits  = 0	# number of digits after dot. (optional)
ordering		= yes	# Is ordering defined for timestamps?
				# (optional, default: no)
tsa_name		= yes	# Must the TSA name be included in the reply?
				# (optional, default: no)
ess_cert_id_chain	= no	# Must the ESS cert id chain be included?
				# (optional, default: no)
EOF

# based on /usr/local/etc/openssl@1.1/openssl.cnf and https://metadatacenter.readthedocs.io/en/latest/install-developer/cert-self-signed/
cat > ${CEDAR_HOME}/CEDAR_CA/openssl-san.cnf << 'EOF'
#
# OpenSSL example configuration file.
# This is mostly being used for generation of certificate requests.
#

# This definition stops the following lines choking if HOME isn't
# defined.
HOME			= .
#RANDFILE		= $ENV::HOME/.rnd
CEDAR_HOME      = $ENV::CEDAR_HOME
CEDAR_HOST      = $ENV::CEDAR_HOST

# Extra OBJECT IDENTIFIER info:
#oid_file		= $ENV::HOME/.oid
oid_section		= new_oids

# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
# extensions		=
# (Alternatively, use a configuration file that has only
# X.509v3 extensions in its main [= default] section.)

[ new_oids ]

# We can add new OIDs in here for use by 'ca', 'req' and 'ts'.
# Add a simple OID like this:
# testoid1=1.2.3.4
# Or use config file substitution like this:
# testoid2=${testoid1}.5.6

# Policies used by the TSA examples.
tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7

####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

#dir		= ./demoCA		# Where everything is kept
dir = $ENV::CEDAR_HOME/CEDAR_CA  # Where everything is kept
default_days = 36500                   # how long to certify for
default_md  = sha256                # use public key default MD

certs		= $dir/certs		# Where the issued certs are kept
crl_dir		= $dir/crl		# Where the issued crl are kept
database	= $dir/index.txt	# database index file.
#unique_subject	= no			# Set to 'no' to allow creation of
					# several certs with same subject.
new_certs_dir	= $dir/newcerts		# default place for new certs.

certificate	= $dir/cacert.pem 	# The CA certificate
serial		= $dir/serial 		# The current serial number
crlnumber	= $dir/crlnumber	# the current crl number
					# must be commented out to leave a V1 CRL
crl		= $dir/crl.pem 		# The current CRL
private_key	= $dir/private/cakey.pem# The private key
RANDFILE	= $dir/private/.rand	# private random number file

x509_extensions	= usr_cert		# The extensions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt 	= ca_default		# Subject Name options
cert_opt 	= ca_default		# Certificate field options

# Extension copying option: use with caution.
# copy_extensions = copy

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crlnumber must also be commented out to leave a V1 CRL.
# crl_extensions	= crl_ext

default_days	= 36500			# how long to certify for
default_crl_days= 30			# how long before next CRL
default_md	= sha256		# use public key default MD
preserve	= no			# keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy		= policy_match

# For the CA policy
[ policy_match ]
countryName		= match
stateOrProvinceName	= match
organizationName	= match
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional

# For the 'anything' policy
# At this point in time, you must list all acceptable 'object'
# types.
[ policy_anything ]
countryName		= optional
stateOrProvinceName	= optional
localityName		= optional
organizationName	= optional
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional

####################################################################
[ req ]
default_bits		= 2048
default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
attributes		= req_attributes
x509_extensions	= v3_ca	# The extensions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix	 : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= HU
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Hungary

localityName			= Locality Name (eg, city)
localityName_default    = Budapest

0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= SZTAKI

# we can do this but it is not needed normally :-)
#1.organizationName		= Second Organization Name (eg, company)
#1.organizationName_default	= World Wide Web Pty Ltd

organizationalUnitName		= Organizational Unit Name (eg, section)
#organizationalUnitName_default	= DSD

commonName			= Common Name (e.g. server FQDN or YOUR name)
commonName_max			= 64
commonName_default      = auth.$CEDAR_HOST

emailAddress			= Email Address
emailAddress_max		= 64
emailAddress_default    = arp@sztaki.hu

# SET-ex3			= SET extension number 3

[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20

unstructuredName		= An optional company name

[ usr_cert ]

# These extensions are added when 'ca' signs a request.

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This is required for TSA certificates.
# extendedKeyUsage = critical,timeStamping

[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1   = artifact.$CEDAR_HOST
DNS.2   = auth.$CEDAR_HOST
DNS.3   = cedar.$CEDAR_HOST
DNS.4   = component.$CEDAR_HOST
DNS.5   = group.$CEDAR_HOST
DNS.6   = impex.$CEDAR_HOST
DNS.7   = internals.$CEDAR_HOST
DNS.8   = messaging.$CEDAR_HOST
DNS.9   = open.$CEDAR_HOST
DNS.10  = openview.$CEDAR_HOST
DNS.11  = repo.$CEDAR_HOST
DNS.12  = resource.$CEDAR_HOST
DNS.13  = schema.$CEDAR_HOST
DNS.14  = submission.$CEDAR_HOST
DNS.15  = terminology.$CEDAR_HOST
DNS.16  = user.$CEDAR_HOST
DNS.17  = valuerecommender.$CEDAR_HOST
DNS.18  = worker.$CEDAR_HOST

[ v3_ca ]


# Extensions for a typical CA


# PKIX recommendation.

subjectKeyIdentifier=hash

authorityKeyIdentifier=keyid:always,issuer

basicConstraints = critical,CA:true

# Key usage: this is typical for a CA certificate. However since it will
# prevent it being used as an test self-signed certificate it is best
# left out by default.
# keyUsage = cRLSign, keyCertSign

# Some might want this also
# nsCertType = sslCA, emailCA

# Include email address in subject alt name: another PKIX recommendation
# subjectAltName=email:copy
# Copy issuer details
# issuerAltName=issuer:copy

# DER hex encoding of an extension: beware experts only!
# obj=DER:02:03
# Where 'obj' is a standard or added object
# You can even override a supported extension:
# basicConstraints= critical, DER:30:03:01:01:FF

[ crl_ext ]

# CRL extensions.
# Only issuerAltName and authorityKeyIdentifier make any sense in a CRL.

# issuerAltName=issuer:copy
authorityKeyIdentifier=keyid:always

[ proxy_cert_ext ]
# These extensions should be added when creating a proxy certificate

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This really needs to be in place for it to be a proxy certificate.
proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

####################################################################
[ tsa ]

default_tsa = tsa_config1	# the default TSA section

[ tsa_config1 ]

# These are used by the TSA reply generation only.
#dir		= ./demoCA		# TSA root directory
dir = $CEDAR_HOME/CEDAR_CA  # Where everything is kept
serial		= $dir/tsaserial	# The current serial number (mandatory)
crypto_device	= builtin		# OpenSSL engine to use for signing
signer_cert	= $dir/tsacert.pem 	# The TSA signing certificate
					# (optional)
certs		= $dir/cacert.pem	# Certificate chain to include in reply
					# (optional)
signer_key	= $dir/private/tsakey.pem # The TSA private key (optional)
signer_digest  = sha256			# Signing digest to use. (Optional)
default_policy	= tsa_policy1		# Policy if request did not specify it
					# (optional)
other_policies	= tsa_policy2, tsa_policy3	# acceptable policies (optional)
digests     = sha1, sha256, sha384, sha512  # Acceptable message digests (mandatory)
accuracy	= secs:1, millisecs:500, microsecs:100	# (optional)
clock_precision_digits  = 0	# number of digits after dot. (optional)
ordering		= yes	# Is ordering defined for timestamps?
				# (optional, default: no)
tsa_name		= yes	# Must the TSA name be included in the reply?
				# (optional, default: no)
ess_cert_id_chain	= no	# Must the ESS cert id chain be included?
				# (optional, default: no)
EOF

cd ${CEDAR_HOME}/CEDAR_CA
echo "++++ Generate an RSA private key for the CA"
openssl genrsa -des3 -out ca.key -passout pass:changeme 4096

echo "++++ Generate a self signed certificate for the  for $CEDAR_HOST"
printf "HU\nHungary\nBudapest\nSZTAKI\nDSD\n$CEDAR_HOST\narp@sztaki.hu\n" | openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -config ./openssl-ca.cnf -passin pass:changeme

echo "++++ Generate an RSA private key for the server"
openssl genrsa -out cedar.$CEDAR_HOST.key 2048

echo "++++ Generate signing request"
printf "\n\n\n\n\n\n\n\n\n" | openssl req -new -sha256 \
  -key cedar.$CEDAR_HOST.key \
  -out cedar.$CEDAR_HOST.csr -config ./openssl-san.cnf

echo "++++ Sign the request"

echo 00 > serial
touch index.txt
touch index.txt.attr

printf "y\ny\n" | openssl ca -cert ca.crt -keyfile ca.key \
  -in cedar.$CEDAR_HOST.csr -out cedar.$CEDAR_HOST.crt \
  -outdir ./ -config ./openssl-san.cnf -verbose -extensions v3_req -passin pass:changeme

ls -la

# Override the default ca.crt in the docker deploy. This will be installed in java's keystore as well.
echo "++++ Copying ca.crt to $CEDAR_DOCKER_HOME/cedar-docker-deploy/cedar-assets/ca/"
cp ./ca.crt $CEDAR_DOCKER_HOME/cedar-docker-deploy/cedar-assets/ca/

# https://stackoverflow.com/questions/66604487/how-do-i-generate-fullchain-pem-and-privkey-pem

#if [[ ! "$CEDAR_HOST" == "metadatacenter.orgx" ]]; then
#  echo "++++ Generating certificates for NGINX"
#  cd ${CEDAR_DOCKER_HOME}/cedar-docker-deploy/cedar-assets/cert/live
#
#  (cd /tmp; \
#    openssl genrsa > privkey.pem; \
#    openssl req -new -x509 -days 36500 -key privkey.pem -subj "/C=HU/ST=Hungary/L=Budapest/O=SZTAKI/OU=DSD/CN=$CEDAR_HOST/emailAddress=arp@sztaki.hu"> fullchain.pem; \
#    openssl x509 -text -noout -in fullchain.pem )
#
#  for d in `ls -d1 *.metadatacenter.orgx`; do
#    # strip .metadatacenter.orgx/
#    d=${d::-20}
#    rm -rf "$d.$CEDAR_HOST"
#    echo "++++ Creating $d.$CEDAR_HOST"
#    mkdir $d.$CEDAR_HOST
#    cp ${CEDAR_HOME}/CEDAR_CA/00.pem $d.$CEDAR_HOST/fullchain.pem
#    cp ${CEDAR_HOME}/CEDAR_CA/ca.key $d.$CEDAR_HOST/privkey.pem
#    #cp /tmp/privkey.pem /tmp/fullchain.pem $d.$CEDAR_HOST
#  done
#
#  # There's one for the root domain as well
#  rm -rf "$CEDAR_HOST"
#  echo "++++ Creating $CEDAR_HOST"
#  mkdir $CEDAR_HOST
#  cp ${CEDAR_HOME}/CEDAR_CA/00.pem $CEDAR_HOST/fullchain.pem
#  cp ${CEDAR_HOME}/CEDAR_CA/ca.key $CEDAR_HOST/privkey.pem
#  #cp /tmp/privkey.pem /tmp/fullchain.pem $CEDAR_HOST
#fi

serial=1
# https://mariadb.com/docs/security/data-in-transit-encryption/create-self-signed-certificates-keys-openssl/
function gen_fullchain_pem {
  echo "gen_fullchain_pem param: $1"

  #openssl genrsa 2048 > ca-key.pem
  #openssl req -new -x509 -nodes -days 365000 \
  #   -key ca-key.pem \
  #   -out ca-cert.pem \
  #   -subj "/C=HU/ST=Hungary/L=Budapest/O=SZTAKI/OU=DSD/CN=arp.orgx/emailAddress=arp@sztaki.hu"

  # Generate the private key and certificate request:
  # ??? -keyout privkey.pem or copy ${CEDAR_HOME}/CEDAR_CA/ca.key as privkey.pem?
  openssl req -newkey rsa:2048 -nodes -days 365000 \
     -keyout privkey.pem \
     -out server-req.pem \
     -subj "/C=HU/ST=Hungary/L=Budapest/O=SZTAKI/OU=DSD/CN=$1/emailAddress=arp@sztaki.hu"

  # Generate the X509 certificate for the domain:
  openssl x509 -req -days 365000 -set_serial $serial \
     -in server-req.pem \
     -out fullchain.pem \
     -CA ${CEDAR_HOME}/CEDAR_CA/ca.crt \
     -CAkey ${CEDAR_HOME}/CEDAR_CA/ca.key -passin pass:changeme

  # Don't need this anymore
  rm server-req.pem

  # Increment serial
  serial=$((serial+1))
}

if [[ ! "$CEDAR_HOST" == "metadatacenter.orgx" ]]; then
  echo "++++ Generating certificates for NGINX"
  cd ${CEDAR_DOCKER_HOME}/cedar-docker-deploy/cedar-assets/cert/live

  for d in `ls -d1 *.metadatacenter.orgx`; do
    # strip .metadatacenter.orgx/
    d=${d::-20}
    rm -rf "$d.$CEDAR_HOST"
    echo "++++ Creating $d.$CEDAR_HOST"
    mkdir $d.$CEDAR_HOST
    cd $d.$CEDAR_HOST
    gen_fullchain_pem $d.$CEDAR_HOST
    cd ..
  done

  # There's one for the root domain as well
  rm -rf "$CEDAR_HOST"
  echo "++++ Creating $CEDAR_HOST"
  mkdir $CEDAR_HOST
  cd $CEDAR_HOST
  gen_fullchain_pem $CEDAR_HOST
  cd ..
fi


