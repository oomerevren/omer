import os
import json
import logging
import requests
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from requests_oauthlib import OAuth1Session

# Loglama yapılandırması - Dosyaya ve konsola
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("/storage/logs/publisher.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("UnifiedPublisher")

class UnifiedPublisher:
    def __init__(self):
        self.timeout = 60

    def x_publish(self, text):
        """X API v2 - Production Ready with Logging"""
        logger.info(f"Attempting to publish to X: {text[:30]}...")
        keys = ["X_CONSUMER_KEY", "X_CONSUMER_SECRET", "X_ACCESS_TOKEN", "X_ACCESS_TOKEN_SECRET"]
        if not all(os.getenv(k) for k in keys):
            logger.error("X credentials missing")
            return {"status": "error", "message": "Missing X credentials"}

        oauth = OAuth1Session(os.getenv("X_CONSUMER_KEY"), client_secret=os.getenv("X_CONSUMER_SECRET"),
                             resource_owner_key=os.getenv("X_ACCESS_TOKEN"),
                             resource_owner_secret=os.getenv("X_ACCESS_TOKEN_SECRET"))
        
        try:
            response = oauth.post("https://api.twitter.com/2/tweets", json={"text": text}, timeout=self.timeout)
            logger.info(f"X API Response Status: {response.status_code}")
            if response.status_code == 201:
                return {"status": "success", "id": response.json()['data']['id']}
            else:
                logger.error(f"X API Error: {response.text}")
                return {"status": "error", "detail": response.json()}
        except Exception as e:
            logger.exception("X Publish Exception")
            return {"status": "error", "message": str(e)}

    def email_publish(self, subject, body, to_email):
        """SMTP Email - Production Ready"""
        logger.info(f"Sending email to {to_email}...")
        sender = os.getenv("SENDER_EMAIL")
        pw = os.getenv("SENDER_PASSWORD")
        if not sender or not pw:
            return {"status": "error", "message": "Email credentials missing"}

        try:
            msg = MIMEMultipart()
            msg['From'] = sender
            msg['To'] = to_email
            msg['Subject'] = subject
            msg.attach(MIMEText(body, 'html'))

            with smtplib.SMTP(os.getenv("SMTP_SERVER", "smtp.gmail.com"), int(os.getenv("SMTP_PORT", 587))) as server:
                server.starttls()
                server.login(sender, pw)
                server.send_message(msg)
            logger.info("Email sent successfully")
            return {"status": "success"}
        except Exception as e:
            logger.error(f"Email failure: {e}")
            return {"status": "error", "message": str(e)}

    def linkedin_publish(self, text):
        """LinkedIn UGC API"""
        logger.info("Attempting to publish to LinkedIn...")
        token = os.getenv("LINKEDIN_ACCESS_TOKEN")
        person_id = os.getenv("LINKEDIN_PERSON_ID")
        if not token or not person_id: return {"status": "error", "message": "Missing LinkedIn credentials"}

        url = "https://api.linkedin.com/v2/ugcPosts"
        headers = {"Authorization": f"Bearer {token}", "X-Restli-Protocol-Version": "2.0.0"}
        payload = {
            "author": f"urn:li:person:{person_id}",
            "lifecycleState": "PUBLISHED",
            "specificContent": {
                "com.linkedin.ugc.ShareContent": {
                    "shareCommentary": {"text": text},
                    "shareMediaCategory": "NONE"
                }
            },
            "visibility": {"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"}
        }
        try:
            res = requests.post(url, json=payload, headers=headers, timeout=self.timeout)
            logger.info(f"LinkedIn Response: {res.status_code}")
            return res.json()
        except Exception as e:
            logger.error(f"LinkedIn Exception: {e}")
            return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3: sys.exit(1)
    platform = sys.argv[1]
    payload = json.loads(sys.argv[2])
    pub = UnifiedPublisher()
    if platform == "x": print(json.dumps(pub.x_publish(payload['text'])))
    elif platform == "email": print(json.dumps(pub.email_publish(payload['subject'], payload['body'], payload['to'])))
    elif platform == "linkedin": print(json.dumps(pub.linkedin_publish(payload['text'])))
