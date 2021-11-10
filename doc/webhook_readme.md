
## Webhook setup
When you want to test Mollie while developing there are certain webhooks that need to be available to public networks.  For this we use ngrok to tunnel our local network securly to the internet. Here is a small guide on how to set this up.

1. install ngrok [Here](https://ngrok.com/download).
2. Run this command ``ngrok http -host-header=koala.rails.local koala.rails.local:3000``
3. You should get something likes this
```
ngrok by @inconshreveable                                                            (Ctrl+C to quit)
                                                                                                     
Session Status                online                                                                 
Account                       xx (Plan: Free)                                                    
Update                        update available (version 2.3.40, Ctrl-U to update)                    
Version                       2.3.35                                                                 
Region                        United States (us)                                                     
Web Interface                 http://127.0.0.1:4040                                                  
Forwarding                    http://bf68e1ab4469.ngrok.io -> http://koala.rails.local:3000          
Forwarding                    https://bf68e1ab4469.ngrok.io -> http://koala.rails.local:3000         
                                                                                                     
Connections                   ttl     opn     rt1     rt5     p50     p90                            
                              13      0       0.00    0.00    0.62    20.47                          
                                                                                                     
HTTP Requests                                                                                        
-------------      
```
4. Copy the first "Forwarding" ngrok link (in this case http://bf68e1ab4469.ngrok.io) and paste it in your `.env` at the var NGROK_HOST.
5. Restart koala and you should be able to test Mollie


