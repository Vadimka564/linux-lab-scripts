pipeline {
    agent any
    options { 
        skipDefaultCheckout(true) 
    }
    environment {
        PACKAGE_NAME = 'count-files'
        PACKAGE_VERSION = '1.0'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Test Script') {
            steps {
                sh 'chmod +x count_files.sh'
                sh 'bash -n count_files.sh'
                sh './count_files.sh'
            }
        }

        stage('Build RPM') {
            agent {
                docker {
                    image 'fedora:latest'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    dnf install -y rpm-build rpmdevtools tar gzip
                    rpmdev-setuptree
                    mkdir -p ~/rpmbuild/SOURCES/${PACKAGE_NAME}-${PACKAGE_VERSION}
                    cp count_files.sh ~/rpmbuild/SOURCES/${PACKAGE_NAME}-${PACKAGE_VERSION}/
                    cd ~/rpmbuild/SOURCES
                    tar czvf ${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz ${PACKAGE_NAME}-${PACKAGE_VERSION}
                    cp ${WORKSPACE}/packaging/rpm/count-files.spec ~/rpmbuild/SPECS/
                    rpmbuild -ba ~/rpmbuild/SPECS/count-files.spec
                    cp ~/rpmbuild/RPMS/noarch/*.rpm ${WORKSPACE}/
                '''
            }
        }

        stage('Build DEB') {
            agent {
                docker {
                    image 'ubuntu:latest'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    apt-get update
                    apt-get install -y build-essential debhelper devscripts fakeroot
                    mkdir -p build/${PACKAGE_NAME}-${PACKAGE_VERSION}
                    cp count_files.sh build/${PACKAGE_NAME}-${PACKAGE_VERSION}/
                    cp -r packaging/deb/debian build/${PACKAGE_NAME}-${PACKAGE_VERSION}/
                    cd build/${PACKAGE_NAME}-${PACKAGE_VERSION}
                    dpkg-buildpackage -us -uc -b
                    cp ../*.deb ${WORKSPACE}/
                '''
            }
        }

        stage('Test RPM Installation') {
            agent {
                docker {
                    image 'oraclelinux:8'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    rpm -ivh ${PACKAGE_NAME}-*.rpm
                    count_files
                    rpm -e ${PACKAGE_NAME}
                '''
            }
        }

        stage('Test DEB Installation') {
            agent {
                docker {
                    image 'ubuntu:latest'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    apt-get update
                    dpkg -i ${PACKAGE_NAME}_*.deb || apt-get install -f -y
                    count_files
                    apt-get remove -y ${PACKAGE_NAME}
                '''
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: '*.rpm, *.deb', allowEmptyArchive: true
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
        always {
            cleanWs()
        }
    }
}
