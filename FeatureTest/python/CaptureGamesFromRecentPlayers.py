import requests
import json

APIKey = "e228a48d184f1deb8506b59b2234be8fcd4c6a01"

headers = {'X-AUTH': APIKey}
rpRequst = requests.get('https://xboxapi.com/v2/recent-players',headers=headers)

rpRequstJson = json.loads(rpRequst.content)

recentPlayerProfiles=[]

for r in rpRequstJson:
	recentPlayerProfiles.append(r['profile_link'])

for r in recentPlayerProfiles:
	profileAddress = r

	rppRequest = requests.get(profileAddress,headers=headers)

	recentPlayerProfile = json.loads(rppRequest.content)

	recentPlayerGamertag = str(recentPlayerProfile['Gamertag'])
	
	ProfileID = str(recentPlayerProfile['id'])
