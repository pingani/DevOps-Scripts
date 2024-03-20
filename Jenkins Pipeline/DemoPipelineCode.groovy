pipeline {
	agent any
	tools {
		// Tools configuration
	    maven "MavenV3"
	    jdk "JavaJDK11"
	}

	stages {
	    stage('Fetch code') {
			// Fetch code from VCM (GitHub)
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
	}
}