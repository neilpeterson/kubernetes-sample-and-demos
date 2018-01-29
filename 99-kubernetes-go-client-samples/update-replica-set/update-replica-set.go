// This sample will update the scheduler in pod spec / template of a replica set.

package main

import (
	"fmt"
	"os"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {

	// Initilization information
	var (
		config *rest.Config
		err    error
	)

	kubeconfig := os.Getenv("KUBECONFIG")

	// Authentication
	config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating client: %v", err)
		os.Exit(1)
	}

	// Kubernetes client
	clientset := kubernetes.NewForConfigOrDie(config)

	// Get pod + replica set name
	pod, _ := clientset.CoreV1().Pods("default").Get("aci-helloworld-1927304711-nl6zg", metav1.GetOptions{})
	rsn := pod.GetOwnerReferences()[0]
	fmt.Println(rsn.Name)

	// Get replica set
	rs, err := clientset.Extensions().ReplicaSets("default").Get("aci-helloworld-1927304711", metav1.GetOptions{})
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(rs.Spec.Template.Spec.SchedulerName)

	// Update replica set shceduler name (template)
	rs.Spec.Template.Spec.SchedulerName = "default"
	_, err = clientset.ExtensionsV1beta1().ReplicaSets("default").Update(rs)
	if err != nil {
		fmt.Println(err)
	}
}
