app.py file - pushed to github has some changes which need to be tested .
jenkins/github will pull these chnages and trigger terraform.

terraform project -> vpc ->public subnet -> route table(Internet gateway) -> ec2 +security grp(app.py is deployed here and can be accessed on internet)

connect to ec2 from VS console : ssh -i ~/.ssh/id_rsa ubuntu@44.200.230.228
