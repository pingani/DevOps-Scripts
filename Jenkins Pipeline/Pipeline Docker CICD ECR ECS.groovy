pipeline {
    agent any
    tools {
	    // Tools configuration
	    maven "MavenV3"
	    jdk "JavaJDK11"
	}
	// Declaring global variables
    environment {
        ecrRegistryCredential = 'ecr:us-east-1:AWSJenkinsUser'
        registryURI = "010107999923.dkr.ecr.us-east-1.amazonaws.com/vprofprojimg"
        vprofileRegistry = "https://010107999923.dkr.ecr.us-east-1.amazonaws.com"
        cluster = "project-vprofile"
        service = "vprofile-webapp-svc"
    }

	// Fetch code from VCS (GitHub)
  	stages {
    stage('Fetch code'){
      steps {
        git branch: 'docker', url: 'https://github.com/adigopulabharath/vprofile-project.git'
      }
    }

	// Performing unit test
    stage('Unit Test'){
      steps {
        sh 'mvn test'
      }
    }

	// Generating checkstyle XML file
    stage ('Checkstyle Analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }


	// Performing Code Analysis and Send reporst to SonarQube
    stage('Sonar Analysis') {
            environment {
             SonarScannerHome = tool 'SonarScannerV4.7'
          }
            steps {
                withSonarQubeEnv('SonarQube') {
                sh '''${SonarScannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }

	// Checking quality gate conditions
    stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

	// Build docker image
    stage('Build App Image') {
       steps {
       
         script {
                dockerImage = docker.build( registryURI + ":$BUILD_NUMBER", "./Docker-files/app/multistage/")
             }

     }
    
    }

	// Upload docker image to ECR
    stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( vprofileRegistry, ecrRegistryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
     }

  // Deploy docker image to ECS (Elastic Container Service)
  stage('Deploy to ECS') {
          steps {
            withAWS(credentials: 'AWSJenkinsUser', region: 'us-east-1') {
            sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
        }
      }
  }

  }
}