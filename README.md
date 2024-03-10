# 2-Branch-CI-CD 
#### 2 Branch CI/CD allows developers to efficiently refine and test applications before deployment to live servers. By leveraging AWS CodeDeploy, CodePipeline, and GitHub repositories - developers can seamlessly integrate and deliver their code through Continuous Integration and Continuous Delivery (CI/CD) pipelines. Developers iteratively build and test applications in the Development branch. When satisified, updates from the development branch are merged to the production branch thus, automatically triggering the production pipeline and deploying the finished application for real-world usage. This streamlined process ensures robust testing and validation before an application reaches production, increasing reliability and stability.

## Architectural Diagram

## Step 1: Create 2 IAM roles - CodeDeploy EC2 Role AND CodeDeploy Role

![IAMroleCD](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/0545c0dc-a8d3-48cf-be96-af143eb6f705)
![IAMroleCD2](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/7c70a633-dc6f-43b2-90ad-9fa405143ab6)

## Step 2: Creating the Development Pipeline - Create Development branch
#### Create a Development or `Dev` branch with GitHub respository. 

## Step 3: Setup EC2 instance
#### Create an EC2 instance in a public subnet. Configure the instance with the EC2 CodeDeploy Role instance profile and edit the EC2's security group to allow Port 80 from anywhere. 

![CDinstance](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/881d5f16-2d0e-4c5d-8e57-bf9dc1e3eba0)
![CDinstance2](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/caf10c00-3e5a-4014-9e45-74cef05db630)
![CDinstance3](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/27e6e045-0e27-414a-838e-6f49e1b3db7a)
![AllowPort80](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/3b6fbf6c-6302-4d38-87a1-6e825cca92f1)


#### Install the NGINX webserver. Use commands: 

```
sudo yum update
sudo yum install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status:
sudo systemctl status nginx
```

#### Install the CodeDeploy Agent using commands: 

```
sudo yum install -y ruby wget
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Check status:
sudo service codedeploy-agent status
```

#### Verify functionality by accessing the instance IP. You should see a default NGINX webpage.
![NginxDefWeb](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/783fd999-85c2-47e7-9184-06be44924848)


## Step 4: Create CodeDeploy Application
#### Head to CodeDeploy > Applications > Create Application > Create Deployment Group

![CreateCDApp](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/c6a1d380-fdca-4dc1-88bc-00ea566cb355)
![DepGroup](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/baff1372-cf29-4314-a78d-9f0b8ba2ec8e)
![DepGroup3](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/d00f9851-5241-4ff7-a483-fe6015bbfb43)
![DepGroup4](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/8b97636c-a026-44df-a9a9-868ef438e075)
![DepGroup5](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/3b1d1f31-29fd-4d9c-8509-fce1f126b7c6)

## Step 5: Create Pipeline
#### Connect to Github repository. Paste in your repo name if it does not pop up on the selection menu. > No filter> > Skip build stage > Select CodeDeploy for as the deploy provider and select the CodeDeploy Application created from Step 3. > Create pipeline. 

![pipeline1](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/292393b2-901d-484e-a636-1d96b7825ad9)
![pipeline2](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/8434d621-edd6-401b-a007-272691f51d99)
![pipeline3](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/a4644488-6bb8-4131-9a2d-92d65fef847d)
![pipeline4](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/6d3a8e9d-9792-4dd4-b754-6d97e633e380)


## Step 6: Create appspec.yml file and upload files

#### Upload files. This example repository will contain `index.html`, `style.css`, and `avatarmaker.png`. 
![CodeDepFiles](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/a08ec26f-ff41-43ea-b190-bc08d8070292)


#### To change the contents of the webpage and include necessary resources, create `appspec.yml` file in the GitHub respository with the following configuration: 

 ```
version: 0.0
os: linux
files:
  - source: /index.html
    destination: /usr/share/nginx/html
  - source: /style.css
    destination: /usr/share/nginx/html
  - source: /avatarmaker.png
    destination: /usr/share/nginx/html
hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 300
      runas: root
  AfterInstall:
    - location: scripts/after_install.sh
      timeout: 300 
      runas: root
 ```

#### Create a `Scripts` folder with files `after_install.sh` and `before_install.sh`. 

#### Within the `before_install.sh` include:

```
#!/bin/bash

# Stop Nginx service
service nginx stop

# Remove existing webpage files
rm -rf /usr/share/nginx/html/*
```

#### Within the `after_install.sh` file include:

```
#!/bin/bash

# Copy updated webpage files to Nginx document root
cp -r /path/to/updated/html/files/* /usr/share/nginx/html/

# Restart Nginx service
service nginx start
```

![CodeDepScripts](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/2d16997d-31bf-4f6b-8ceb-49b2180bcc81)

## Step 7: Verify Functionality
#### Refresh the webpage. If everything is properly configured, you will be able to see the new webpage you've added! Any changes made to the GitHub repository will be updated automatically to the instance as well.

![CDWebpage](https://github.com/ericincloud/AWS-CodePipeline-and-CodeDeploy/assets/144301872/f092eb00-c2cc-471b-ac93-9061bbe40e64)

## Step 8: Create the Production Pipeline and Branch
#### Create a Production or `Prod` branch in GitHub repository.

#### Repeat Steps 3 to 5 to create Production pipeline.

## Step 9: Merge Dev and Prod
#### When satisfied with the resources in the `Dev` branch, merge with the `Prod` branch in the GitHub repository. This will send contents from the Dev branch to the Prod branch - triggering the production pipeline. The resources will mirror the contents within the Dev branch. 

![merge](https://github.com/ericincloud/2-Branch-CI-CD/assets/144301872/e933ccac-2d67-49c0-9ace-d2a22e84d1ed)
![merge2](https://github.com/ericincloud/2-Branch-CI-CD/assets/144301872/7d152467-f54f-4a17-9110-ec2407dbb1a4)
![merged](https://github.com/ericincloud/2-Branch-CI-CD/assets/144301872/19aa7569-79a2-4ecf-9572-b4571c9bf91b)

### Finish! Congratulations you've setup and configured 2-Branch CI/CD using AWS CodeDeploy and CodePipeline!

## Notes
* Make sure to install the CodeDeploy agent on EC2 instance.
* Change `destination` parameter in the `appspec.yml` file based on the OS/distributon + scripts.
* Delete and recreate scripts files in proper order (before 1st, after 2nd) if script error occurs.
* Connect/Install a new app when using a new repository.
* Make sure EC2 instance and CodeDeploy Application has proper IAM permissions.
* Use "Release Change" to manually trigger pipeline in CodePipeline

## Reference
* Stop CodeDeploy Agent <br>
  `sudo service codedeploy-agent stop`

* Start CodeDeploy Agent <br>
  `sudo service codedeploy-agent start`

* Check CodeDeploy Agent Status <br>
  `sudo service codedeploy-agent status`

  




