pipeline {
    agent any
    
    environment {
        POSTGRES_USER     = credentials('POSTGRES_USER')
        POSTGRES_PASSWORD = credentials('POSTGRES_PASSWORD')
        POSTGRES_DB       = credentials('POSTGRES_DB')
        OPENAI_API_KEY    = credentials('OPENAI_API_KEY')
        LANGFLOW_URL      = "http://langflow-dev-1:7860"
    }

    parameters {
        string(name: 'FLOW_IDS', defaultValue: '', description: 'Comma-separated flow IDs to deploy')
        string(name: 'SERVICE_NAMES', defaultValue: '', description: 'Comma-separated service names')
    }
    
    stages {
        stage('Export Selected Flows') {
            steps {
                script {
                    def flowIds = params.FLOW_IDS.split(',').collect { "\"${it.trim()}\"" }.join(',')
                    
                    sh """
                        curl -X POST \\
                          "$LANGFLOW_URL/api/v1/flows/download/" \\
                          -H "accept: application/json" \\
                          -H "Content-Type: application/json" \\
                          -d '[${flowIds}]' \\
                          --output flows/exported-flows.json
                        
                        # 받아진 파일 확인
                        cat flows/exported-flows.json
                    """
                }
            }
        }
        
        stage('Build and Deploy') {
            steps {
                script {
                    def flowIds = params.FLOW_IDS.split(',')
                    def serviceNames = params.SERVICE_NAMES.split(',')
                    
                    for (int i = 0; i < flowIds.size(); i++) {
                        def serviceName = serviceNames[i].trim()
                        def port = 8001 + i
                        
                        sh """
                            docker build -t ${serviceName}:latest .
                            docker run -d --name ${serviceName} -p ${port}:7860 --network flow-net \\
                                -e LANGFLOW_DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB} \\
                                -e OPENAI_API_KEY=${OPENAI_API_KEY} \\
                                ${serviceName}:latest
                        """
                    }
                }
            }
        }
    }
}