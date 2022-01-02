https://medium.com/rahasak/set-up-ssl-certificates-on-nginx-c51f7dc00272

1. ca.key
   openssl genrsa -des3 -out ca.key 4096

2. ca.crt
   openssl req -new -x509 -days 365 -key ca.key -out ca.crt

3. server.key
   openssl genrsa -des3 -out server.key 1024

4. server.csr
   openssl req -new -key server.key -out server.csr

5. sign => server.crt
   openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

6 remove pass phase from server key
openssl rsa -in server.key -out temp.key
rm server.key
mv temp.key server.key
