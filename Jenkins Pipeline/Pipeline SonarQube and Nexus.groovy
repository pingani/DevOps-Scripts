pipeline {
	agent any
	tools {
		// Tools configuration
	    maven "MavenV3"
	    jdk "JavaJDK11"
	}

	stages {
	    stage('Fetch code') {
			// Fetch code from VCS (GitHub)
            steps {
               git branch: 'main', url: 'https://github.com/adigopulabharath/vprofile-project.git'
            }

	    }

	    stage('Build'){
			// Build
	        steps{
	           sh 'mvn clean install -DskipTests'
	        }

	        post {
				// Post build actions, Archive, Notifications
	           success {
	              echo 'Now Archiving it...'
	              archiveArtifacts artifacts: '**/target/*.war'
	           }
	        }
	    }

	    stage('Unit Test') {
			// Performing unit test
            steps{
                sh 'mvn test'
            }
        }

		 stage('Checkstyle Analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

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

		stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }   
        }

        stage("Upload Artifact"){
            steps{
                nexusArtifactUploader(
                  nexusVersion: 'nexus3',
                  protocol: 'http',
                  nexusUrl: '172.31.84.50:8081',
                  groupId: 'DevOps',
                  version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                  repository: 'vprofile-project',
                  credentialsId: 'NexusLogin',
                  artifacts: [
                    [artifactId: 'vprofproj',
                     classifier: '',
                     file: 'target/vprofile-v2.war',
                     type: 'war']
                     ]
                )
            }
        }

	}
    
}