# mss-us-east-db-springboot-app

node {
     def buildNumber = BUILD_NUMBER
     def mvnHome = tool 'maven-build'

    stage ("checkout")  {
    git credentialsId: 'git-authentication-jenkins-login', url: 'https://github.com/agunu2025/mss-mongo-springboot-app.git'
    }


  stage ('build')  {
    sh "${mvnHome}/bin/mvn clean install "
    }

    stage('Build Docker Image'){
        sh "docker build . -t agunu2025/mss-mongodb-app:${buildNumber}"
    }

     stage('Push Docker Image'){
         withCredentials([string(credentialsId: 'dockerAuthenticationpublic', variable: 'dockerAuthenticationpublic')])  {
          sh "docker login -u agunu2025 -p ${dockerAuthenticationpublic}"
        }
        sh "docker push agunu2025/mss-mongodb-app:${buildNumber} "
     }

      stage("Deploy To plab02"){
      sh "chmod +x global.yml docker-compose-plab02.yml  "
      sshagent(['aws-private-key-connection']) {
       sh "scp -o StrictHostKeyChecking=no global.yml docker-compose-plab02.yml  ec2-user@3.138.158.136:/home/ec2-user/"
       sh 'docker-compose -f global.yml -f docker-compose-qlab02.yml  up -d '
       sh 'rm -rf global.yml docker-compose-qlab02.yml '
       }
      }

      stage("Deploy To qlab02"){
      sshagent(['SSH_PRIVATE_KEY_docker']) {
        sh "scp -o StrictHostKeyChecking=no global.yml docker-compose-qlab02.yml  ec2-user@3.138.158.137:/home/ec2-user/"
       }
       sh "ssh -o StrictHostKeyChecking=no ec2-user@3.141.10.50"
       sh "ssh ec2-user@3.141.10.50 docker-compose -f global.yml -f docker-compose-qlab02.yml  up "
      }

}
