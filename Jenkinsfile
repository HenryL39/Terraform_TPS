pipeline{
    agent{
        any
    }
    stages{
        stage("Pull"){
            steps{
                git branch: 'projet_terra', credentialsId: '48b13df2-b9bb-478c-bd41-8bac9573dd25', url: 'https://github.com/HenryL39/Terraform_TPS.git'
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