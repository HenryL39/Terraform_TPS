pipeline{
    agent{
        label "docker-slave"
    }
    stages{
        stage("Pull"){
            steps{
                git branch: 'source', credentialsId: '8ce10fc1-e7b8-4a1b-bb26-d494fe5214ea', url: 'https://github.com/HenryL39/ProjetCD.git'
            }
        }
        stage("Container"){
            steps{
                echo "Using spotify plugin"
            }
        }
        stage("Deploy"){
            steps{
                sh "mvn deploy -s settings.xml -Dmaven.test.failure.ignore=true"
            }
        }
        stage("Release"){
            steps{
                sh "mvn clean -DskipTests -Darguments=-DskipTests --settings settings.xml release:clean release:prepare release:perform"
            }
        }
    }
}