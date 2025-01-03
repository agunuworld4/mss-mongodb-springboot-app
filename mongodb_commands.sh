#!/bin/bash

#k8s-deployment.sh
mss_pod_app="mongo"
serviceName="mongo"
#imageName="eagunuworld/numeric-app:docker pull eagunuworld/numeric-app:ddba18bd401f3eeb0ee097eb56dd8f76d1953e0b"
imageName="mongo"
#applicationURL="http://devsecops-demo.eastus.cloudapp.azure.com/"
#applicationURI="/increment/99"

#sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
echo $mss_pod_app
echo $serviceName
echo $imageName
# #kubectl create ns ibm-ucd
kubectl -n ibm-ucd get deploy ${mss_pod_app} > /dev/null

if [[ $? -ne 0 ]]; then
    echo "mss pod Dployment ${mss_pod_app} doesn't exist,Appying kubectl commands"
    kubectl -n ibm-ucd apply -f mongo-pod.yml
else
  echo "RollBack Since Latest Deployment Failed"
 kubectl -n ibm-ucd rollout undo deploy ${mss_pod_app}
 echo "Deployment ${mss_pod_app} Rollout is Success"
fi
#!/bin/bash

# #k8s-deployment.sh
# # sh '''final_tag=$(echo $VERSION | tr -d ' ')
# #  echo ${final_tag}test
# #  sed -i "s/BUILD_TAG/$final_tag/g"  docker-compose.yml
# #  '''
#  #dockerimage=$(awk 'NR==1 {print $2}' Dockerfile)
#  final_tag=$(echo $VERSION | tr -d ' ')
#  echo ${final_tag}test
#  #echo $dockerimage
# sed -i "s/BUILD_TAG/$final_tag/g"  k8s_deployment_service.yaml
# #sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
# kubectl -n default get deployment ${deploymentName} > /dev/null
#
# if [[ $? -ne 0 ]]; then
#     echo "deployment ${deploymentName} doesnt exist"
#     kubectl -n default apply -f k8s_deployment_service.yaml
# else
#     echo "deployment ${deploymentName} exist"
#     echo "image name - ${imageName}"
#     #kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} #--record=true
# fi
