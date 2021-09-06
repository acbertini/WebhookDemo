@RestResource(urlMapping='/api/Webhooks/pushDetailsdemo/*')
global with sharing class webhookSubscriptionDemo {
    @HttpPost
    global static void handleNotification() {

        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

			String hashedval = request.headers.get('X-Hub-Signature-256');
			System.debug('hashedval: ' + hashedval);
            Blob bB = request.requestBody;
            System.debug(bB.toString());
            
            System.debug('Secret value matched and source can be trusted');
            
            JSONParser parser = JSON.createParser(request.requestBody.toString());
            
            pusher ps;
            head_commit hc;
            String repo;
            
            while (parser.nextToken() != null) {
                if (parser.getText() == 'pusher') {
                    System.debug('Inside pusher');
                    
                    parser.nextToken();
                    ps = (pusher)parser.readValueAs(pusher.class);
                    System.debug(ps);
                }
                
                if (parser.getText() == 'head_commit') {
                    System.debug('Inside head_commit');
                    
                    parser.nextToken();
                    hc = (head_commit)parser.readValueAs(head_commit.class);
                }
                
                if (parser.getText() == 'full_name') {
                    System.debug('Inside full_name');
                    
                    parser.nextToken();
                    repo = parser.getText();
                    System.debug(repo);
                }
                
                GitHub_PushDetails__c detail = new GitHub_PushDetails__c();
                detail.Committer_Name__c = ps != null ? ps.name : '';
                detail.Committer_Email__c = ps != null ? ps.email : '';
                //detail.Commit_Message__c = hc != null ? hc.message : '';
                insert detail;
                
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Success', 'Processed Sucessfully')));
            } 

    	} catch (Exception e) {
                System.debug('Exception  Happened:' + e.getMessage());
        }
    }
        
    public class SFDCResponse {      
        public String response;
        public String message;
            
        public SFDCResponse(String response, String message) {
            response = this.response;
            message = this.message;
        }
    }
        
    public class pusher {
        public String name;
        public String email;
        public pusher(String name, String email) {
            name = this.name;
            email = this.email;
        }
    }
    
   public class head_commit {
        public String name;
        public String email;
        public head_commit(String name, String email) {
            name = this.name;
            email = this.email;
        }
    }
}