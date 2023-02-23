pipeline {
    agent any

    stages {

        stage('Test 1') {
            when {
                expression {
                    env.BRANCH_NAME == 'source'
                }
            }
            steps {
                echo 'Stage Test 1: Source'
            }
        }

        stage('Test 2') {
            when {
                expression {
                    env.BRANCH_NAME == 'terraform'
                }
            }
            steps {
                echo 'Stage Test 2: Terraform'
            }
        }
    }
}