pipeline{
    
    agent any
    
    tools{
        maven 'mymaven'
    }
    
    stages{
        stage('Clone Repo')
        {
            steps{
                git 'https://github.com/nikitaks97/star-agile-insurance-project.git'
            }
        }
        stage('Test Code')
        {
            steps{
                sh 'mvn test'
            }
        }
        stage('Build Code')
        {
            steps{
                sh 'mvn package'
            }
        }
        stage('Build Image')
        {
            steps{
                sh 'docker build -t capstone_project3:$BUILD_NUMBER .'
            }
        }

        stage('Push the Image to dockerhub')
        {
            steps{
                
        withCredentials([string(credentialsId: 'docker', variable: 'docker')]) 
                {
               sh 'docker login -u  nikitaks997797 -p ${docker} '
               }
                sh 'docker tag capstone_project3:$BUILD_NUMBER nikitaks997797/capstone_project3:$BUILD_NUMBER '
                sh 'docker push nikitaks997797/capstone_project3:$BUILD_NUMBER'
            }
        }
        
    }
}