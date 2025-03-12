#!/usr/bin/bash

function step_info() {
    echo "Performing backup of $step..."
}

function step_status() {
    local exit_status=$?
    if [ $exit_status -eq 0 ]; then
        printf "$step backup completed.\n\n"
    else
        all_done=0
        failed_steps+=("$step")
        printf "$step backup failed with status $exit_status\n\n" >&2
    fi
}

filedate=$(date +'%Y_%m_%d__%H_%M_%S__%Z')

#create local directory to store backup files in
bkp_dirname="backup_CCD_$(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers | egrep '^.+-cluster[0-9]+-capi$' | sed 's/-cluster/_vpod/; s/-capi//')__$filedate"
mkdir "$bkp_dirname"
echo "Created directory:"
echo "$bkp_dirname"
cd "$bkp_dirname"
bkp_location=$(pwd)
echo "Backup files will be stored on:"
hostname
echo "in the following location:"
printf "$bkp_location\n\n"

all_done=1
failed_steps=()

#labels
step="labels"
step_info
filename="labels__$filedate" && for node in $(kubectl get nodes -o custom-columns=NAME:.metadata.name --no-headers); do echo "$node" && kubectl label --list nodes $node | sort -f && echo; done > "$filename"
step_status

#taints
step="taints"
step_info
filename="taints__$filedate" && kubectl get nodes -o=custom-columns=NAME:.metadata.name,TAINTS:.spec.taints > "$filename"
step_status

#routes_and_rules
step="routes_and_rules"
step_info
fileall="routes_rules_all__$filedate" && for ipaddr in $(kubectl get node -A -o custom-columns=INTERNAL-IP:.status.addresses[0].address --no-headers); do ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -q $ipaddr "printf '#----------------------------------------------------------------------#\n' && hostname && printf '\n#sudo ip r show table all\n' && sudo ip r show table all && printf '\n#sudo ip -4 rule show\n' && sudo ip -4 rule show && printf '\n#sudo ip -6 rule show\n' && sudo ip -6 rule show && printf '\n\n'"; done > "$fileall" && cat $fileall | grep -Ev 'scope link|proto kernel|proto bird|dev cali[0-9a-f]{11}' > "routes_rules_filtered__$filedate"
step_status

#kubelet_options
step="kubelet_options"
step_info
dirname="kubelet_options__$filedate" && mkdir "$dirname" && cd "$dirname" && for node in $(kubectl get nodes -o custom-columns=NAME:.metadata.name --no-headers); do echo "$node" && kubectl get --raw "/api/v1/nodes/$node/proxy/configz" | jq > "$node.json"; echo; done && cd ..
step_status

#ccdadmconfig_secret
step="ccdadmconfig_secret"
step_info
ns=$(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers | egrep '^.+-cluster[0-9]+-capi$') && filename="ccdadmconfig_secret__$filedate.json" && kubectl -n "$ns" get secrets ccdadmconfig -o json | jq -r .data.config | base64 -d | jq > "$filename"
step_status

#bmhosts-data_secret
step="bmhosts-data_secret"
step_info
#for now obtaining ns is duplicated in ccdadmconfig_secret and bmhosts-data_secret for simple error handling in case the namespace does not exist
ns=$(kubectl get ns -o custom-columns=NAME:.metadata.name --no-headers | egrep '^.+-cluster[0-9]+-capi$') && filename="bmhosts-data_secret__$filedate.yaml" && kubectl -n "$ns" get secrets bmhosts-data -o json | jq -r .data.bmhosts | base64 -d > "$filename"
step_status

#authorized_keys__masters
step="authorized_keys__masters"
step_info
tempfile=$(mktemp) && for ipaddr in $(kubectl get node -A -o custom-columns=INTERNAL-IP:.status.addresses[0].address -l "node-role.kubernetes.io/control-plane" --no-headers); do ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -q "$ipaddr" "cat ~/.ssh/authorized_keys | grep '\S'" >> "$tempfile"; done && keysfile="authorized_keys__masters__$filedate" && sort -u "$tempfile" > "$keysfile" && rm -f "$tempfile"
step_status

#ecfe-ccdadm_configmap
step="ecfe-ccdadm_configmap"
step_info
filename="ecfe-ccdadm_cm__$filedate.yaml" && kubectl get cm -n kube-system ecfe-ccdadm -o yaml > "$filename"
step_status

echo "Backup files location:"
echo "$bkp_location"

    if [ $all_done -eq 1 ]; then
        printf "All the backup steps were performed successfully. Please transfer directory $bkp_dirname to STC backup location.\n\n"
    else
        echo "Not all the backup steps were successful - the following failed:" >&2
        for f_step in "${failed_steps[@]}"; do
            echo "$f_step" >&2
        done
        printf "Check the errors!\n\n" >&2
    fi
