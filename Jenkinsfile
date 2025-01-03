//${library.jenkins-slack-library.version}
//@Library('Slack-us-east-jenkins-master_snow_prod') _

pipeline {

  agent { label 'google-jenkins-slave' }

  options {
       buildDiscarder logRotator(
           artifactDaysToKeepStr: '5',
           artifactNumToKeepStr: '5',
           daysToKeepStr: '5',
           numToKeepStr: '5')
          timestamps()
        }

  tools {
      maven 'UI_Maven3..9.9'
  }

  environment {
    BUILD_NUMBER = "${env.BUILD_ID}"
    SonarQubeTokenAcc = "sonarqube-secret-text-java-project"
    //eagunu docker registry repository
    registry = "danle360/mongodb-springboot-app"
    //eagunu dockerhub registry
    registryCredential = 'dan360-dockerhub-username-and-pwd'
    dockerImage = ''
    //latest_version_update
    imageVersion = "danle360/mongodb-springboot-app:v$BUILD_NUMBER"
    // This can be nexus3 or nexus2
    NEXUS_VERSION = "nexus3"
    // This can be http or https
    NEXUS_PROTOCOL = "http"
    // Where your Nexus is running
    NEXUS_URL = "34.73.34.80:8081"
    // Repository where we will upload the artifact
    NEXUS_REPOSITORY = "mongodb-springboot-app"
    // Jenkins credential id to authenticate to Nexus OSS
    NEXUS_CREDENTIAL_ID = "nexus-username-password-creds"
    //sonar qube
  }

  stages {
    stage('Cloning Git') {
            steps {
                //checkout([$class: 'GitSCM', branches: [[name: '*/master_snow_prod']], extensions: [], userRemoteConfigs: [[credentialsId: 'democalculus-github-login-creds', url: 'https://github.com/democalculus/mongodb-springboot-app.git']]])
              git credentialsId: 'GIT_CREDENTIALS', url:  'https://github.com/Danle360/mongodb-springboot-app.git',branch: 'master_snow_prod'

            }
        }

    stage ('Build wep app war file') {
      steps {
      sh 'mvn clean package'
       }
    }
   //hardcoded in pom.xml file
    // stage ('SonarQubeReport') {
    //   steps {
    //   sh 'mvn clean package sonar:sonar'
    // }
    //  }

  stage ('SonarQube Plugin Report') {
       steps {
         withSonarQubeEnv('SonarQubeAccessToken') {
         sh "mvn clean package sonar:sonar"
          }
        }
      }

      stage("publish to nexus") {
          steps {
              script {
                  // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                  pom = readMavenPom file: "pom.xml";
                  // Find built artifact under target folder
                  filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                  // Print some info from the artifact found
                  echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                  // Extract the path from the File found
                  artifactPath = filesByGlob[0].path;
                  // Assign to a boolean response verifying If the artifact name exists
                  artifactExists = fileExists artifactPath;

                  if(artifactExists) {
                      echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";

                      nexusArtifactUploader(
                          nexusVersion: NEXUS_VERSION,
                          protocol: NEXUS_PROTOCOL,
                          nexusUrl: NEXUS_URL,
                          groupId: pom.groupId,
                          version: BUILD_NUMBER,
                          repository: NEXUS_REPOSITORY,
                          credentialsId: NEXUS_CREDENTIAL_ID,
                          artifacts: [
                              // Artifact generated such as .jar, .ear and .war files.
                              [artifactId: pom.artifactId,
                              classifier: '',
                              file: artifactPath,
                              type: pom.packaging]
                          ]
                      );

                  } else {
                      error "*** File: ${artifactPath}, could not be found";
                  }
              }
             }
         }

      stage('Building our image') {
           steps{
                script {
                   dockerImage = docker.build registry + ":v$BUILD_NUMBER"
                  }
              }
           }

      // stage('QA approve') {
      //        steps {
      //          notifySlack("Do you approve QA deployment? $registry/job/$BUILD_NUMBER", [])
      //            input 'Do you approve QA deployment?'
      //            }
      //        }

      stage('Deploy our image') {
         steps{
             script {
                docker.withRegistry( '', registryCredential ) {
               dockerImage.push()
              }
            }
           }
         }

    stage('updating image version') {
          steps {
                sh "bash update_image_version.sh"
                }
            }

    stage('DockerCleanUp ConfigMap') {
                 steps {
                   parallel(
                     "Cleaning up docker Images": {
                          sh 'docker rmi  ${imageVersion}'
                         },
                         "configureMap-Namespace": {
                           sh 'bash cmSecret-ns.sh'
                            }
                      )
                  }
            }

    stage('springboot Deployment') {
            steps {
              parallel(
                "Deployment": {
                     sh 'bash springboot_commands.sh'
                    },
                    "Rollout Status": {
                      sh 'bash springboot-rollout.sh'
                        },
                        "mongodb commands": {
                       sh 'bash mongodb_commands.sh'
                       }

                      )
                    }
                }

  // stage ('Deploying To EKS') {
  //      steps {
  //      sh 'kubectl apply -f mss-us-east-2-prod.yml'
  //      }
  //     }

 }  //This line end the pipeline stages
  //post {   //This line start the post script this line should be uncommittted
        //always { this line should be uncommittted
          //junit 'target/surefire-reports/*.xml'
         // jacoco execPattern: 'target/jacoco.exec'
        // pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
         //dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
         //publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])

         //Use sendNotifications.groovy from shared library and provide current build result as parameter
         //sendNotification currentBuild.result this line should be uncommittted
       // } this line should be uncommittted

    //success {
      //script {
        /* Use slackNotifier.groovy from shared library and provide current build result as parameter */
        //env.failedStage = "none"
        //env.emoji = ":white_check_mark: :tada: :thumbsup_all:"
        //sendNotification currentBuild.result
      //}
      //}

    // failure {
    //}
  //}  //this line close post script stage this line should be uncommittted
}    //This line close the jenkins pipeline
