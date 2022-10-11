{{/*
Channel config template
*/}}
{{- define "fabric-operator-hlf.channel-configtx" -}}
#
# Copyright contributors to the Hyperledger Fabric Operator project
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# 	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

---
################################################################################
#
#   Section: Organizations
#
#   - This section defines the different organizational identities which will
#   be referenced later in the configuration.
#
################################################################################
Organizations:

  # SampleOrg defines an MSP using the sampleconfig.  It should never be used
  # in production but may be used as a template for other definitions
  - &OrdererOrg
    # DefaultOrg defines the organization which is used in the sampleconfig
    # of the fabric.git development environment
    Name: OrdererOrg

    # ID to load the MSP definition as
    ID: OrdererMSP

    # MSPDir is the filesystem path which contains the MSP configuration
    MSPDir: ../../temp/channel-msp/ordererOrganizations/org0/msp

    # Policies defines the set of policies at this level of the config tree
    # For organization policies, their canonical path is usually
    #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
    Policies:
      Readers:
        Type: Signature
        Rule: "OR('OrdererMSP.member')"
      Writers:
        Type: Signature
        Rule: "OR('OrdererMSP.member')"
      Admins:
        Type: Signature
        Rule: "OR('OrdererMSP.admin')"

    OrdererEndpoints:
      - org0-orderersnode1.${KUBE_DNS_DOMAIN}:7050
      - org0-orderersnode2.${KUBE_DNS_DOMAIN}:7050
      - org0-orderersnode3.${KUBE_DNS_DOMAIN}:7050

  - &Org1
    # DefaultOrg defines the organization which is used in the sampleconfig
    # of the fabric.git development environment
    Name: Org1MSP

    # ID to load the MSP definition as
    ID: Org1MSP

    MSPDir: ../../temp/channel-msp/peerOrganizations/org1/msp

    # Policies defines the set of policies at this level of the config tree
    # For organization policies, their canonical path is usually
    #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
    Policies:
      Readers:
        Type: Signature
        Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
      Writers:
        Type: Signature
        Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
      Admins:
        Type: Signature
        Rule: "OR('Org1MSP.admin')"
      Endorsement:
        Type: Signature
        Rule: "OR('Org1MSP.peer')"

    # leave this flag set to true.
    AnchorPeers:
      # AnchorPeers defines the location of peers which can be used
      # for cross org gossip communication.  Note, this value is only
      # encoded in the genesis block in the Application section context
      - Host: org1-peer1.${KUBE_DNS_DOMAIN}
        Port: 7051

  - &Org2
    # DefaultOrg defines the organization which is used in the sampleconfig
    # of the fabric.git development environment
    Name: Org2MSP

    # ID to load the MSP definition as
    ID: Org2MSP

    MSPDir: ../../temp/channel-msp/peerOrganizations/org2/msp

    # Policies defines the set of policies at this level of the config tree
    # For organization policies, their canonical path is usually
    #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
    Policies:
      Readers:
        Type: Signature
        Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
      Writers:
        Type: Signature
        Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
      Admins:
        Type: Signature
        Rule: "OR('Org2MSP.admin')"
      Endorsement:
        Type: Signature
        Rule: "OR('Org2MSP.peer')"

    AnchorPeers:
      # AnchorPeers defines the location of peers which can be used
      # for cross org gossip communication.  Note, this value is only
      # encoded in the genesis block in the Application section context
      - Host: org2-peer1.${KUBE_DNS_DOMAIN}
        Port: 7051

################################################################################
#
#   SECTION: Capabilities
#
#   - This section defines the capabilities of fabric network. This is a new
#   concept as of v1.1.0 and should not be utilized in mixed networks with
#   v1.0.x peers and orderers.  Capabilities define features which must be
#   present in a fabric binary for that binary to safely participate in the
#   fabric network.  For instance, if a new MSP type is added, newer binaries
#   might recognize and validate the signatures from this type, while older
#   binaries without this support would be unable to validate those
#   transactions.  This could lead to different versions of the fabric binaries
#   having different world states.  Instead, defining a capability for a channel
#   informs those binaries without this capability that they must cease
#   processing transactions until they have been upgraded.  For v1.0.x if any
#   capabilities are defined (including a map with all capabilities turned off)
#   then the v1.0.x peer will deliberately crash.
#
################################################################################
Capabilities:
  # Channel capabilities apply to both the orderers and the peers and must be
  # supported by both.
  # Set the value of the capability to true to require it.
  Channel: &ChannelCapabilities
    # V2_0 capability ensures that orderers and peers behave according
    # to v2.0 channel capabilities. Orderers and peers from
    # prior releases would behave in an incompatible way, and are therefore
    # not able to participate in channels at v2.0 capability.
    # Prior to enabling V2.0 channel capabilities, ensure that all
    # orderers and peers on a channel are at v2.0.0 or later.
    V2_0: true

  # Orderer capabilities apply only to the orderers, and may be safely
  # used with prior release peers.
  # Set the value of the capability to true to require it.
  Orderer: &OrdererCapabilities
    # V2_0 orderer capability ensures that orderers behave according
    # to v2.0 orderer capabilities. Orderers from
    # prior releases would behave in an incompatible way, and are therefore
    # not able to participate in channels at v2.0 orderer capability.
    # Prior to enabling V2.0 orderer capabilities, ensure that all
    # orderers on channel are at v2.0.0 or later.
    V2_0: true

  # Application capabilities apply only to the peer network, and may be safely
  # used with prior release orderers.
  # Set the value of the capability to true to require it.
  Application: &ApplicationCapabilities
    # V2_0 application capability ensures that peers behave according
    # to v2.0 application capabilities. Peers from
    # prior releases would behave in an incompatible way, and are therefore
    # not able to participate in channels at v2.0 application capability.
    # Prior to enabling V2.0 application capabilities, ensure that all
    # peers on channel are at v2.0.0 or later.
    V2_0: true

################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

  # Organizations is the list of orgs which are defined as participants on
  # the application side of the network
  Organizations:

  # Policies defines the set of policies at this level of the config tree
  # For Application policies, their canonical path is
  #   /Channel/Application/<PolicyName>
  Policies:
    Readers:
      Type: ImplicitMeta
      Rule: "ANY Readers"
    Writers:
      Type: ImplicitMeta
      Rule: "ANY Writers"
    Admins:
      Type: ImplicitMeta
      Rule: "MAJORITY Admins"
    LifecycleEndorsement:
      Type: Signature
      Rule: "OR('Org1MSP.peer','Org2MSP.peer')"
    Endorsement:
      Type: Signature
      Rule: "OR('Org1MSP.peer','Org2MSP.peer')"

  Capabilities:
    <<: *ApplicationCapabilities
################################################################################
#
#   SECTION: Orderer
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters
#
################################################################################
Orderer: &OrdererDefaults

  # Orderer Type: The orderer implementation to start
  OrdererType: etcdraft

  EtcdRaft:
    Consenters:
      - Host: org0-orderersnode1.${KUBE_DNS_DOMAIN}
        Port: 7050
        ClientTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem
        ServerTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem
      - Host: org0-orderersnode2.${KUBE_DNS_DOMAIN}
        Port: 7050
        ClientTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode2/tls/signcerts/tls-cert.pem
        ServerTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode2/tls/signcerts/tls-cert.pem
      - Host: org0-orderersnode3.${KUBE_DNS_DOMAIN}
        Port: 7050
        ClientTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode3/tls/signcerts/tls-cert.pem
        ServerTLSCert: ../../temp/channel-msp/ordererOrganizations/org0/orderers/org0-orderersnode3/tls/signcerts/tls-cert.pem


    # Options to be specified for all the etcd/raft nodes. The values here
    # are the defaults for all new channels and can be modified on a
    # per-channel basis via configuration updates.
    Options:
      # TickInterval is the time interval between two Node.Tick invocations.
      #TickInterval: 500ms default
      TickInterval: 2500ms

      # ElectionTick is the number of Node.Tick invocations that must pass
      # between elections. That is, if a follower does not receive any
      # message from the leader of current term before ElectionTick has
      # elapsed, it will become candidate and start an election.
      # ElectionTick must be greater than HeartbeatTick.
      # ElectionTick: 10 default
      ElectionTick: 5

      # HeartbeatTick is the number of Node.Tick invocations that must
      # pass between heartbeats. That is, a leader sends heartbeat
      # messages to maintain its leadership every HeartbeatTick ticks.
      HeartbeatTick: 1

      # MaxInflightBlocks limits the max number of in-flight append messages
      # during optimistic replication phase.
      MaxInflightBlocks: 5

      # SnapshotIntervalSize defines number of bytes per which a snapshot is taken
      SnapshotIntervalSize: 16 MB

  # Batch Timeout: The amount of time to wait before creating a batch
  BatchTimeout: 2s

  # Batch Size: Controls the number of messages batched into a block
  BatchSize:

    # Max Message Count: The maximum number of messages to permit in a batch
    MaxMessageCount: 10

    # Absolute Max Bytes: The absolute maximum number of bytes allowed for
    # the serialized messages in a batch.
    AbsoluteMaxBytes: 99 MB

    # Preferred Max Bytes: The preferred maximum number of bytes allowed for
    # the serialized messages in a batch. A message larger than the preferred
    # max bytes will result in a batch larger than preferred max bytes.
    PreferredMaxBytes: 512 KB

  # Organizations is the list of orgs which are defined as participants on
  # the orderer side of the network
  Organizations:

  # Policies defines the set of policies at this level of the config tree
  # For Orderer policies, their canonical path is
  #   /Channel/Orderer/<PolicyName>
  Policies:
    Readers:
      Type: ImplicitMeta
      Rule: "ANY Readers"
    Writers:
      Type: ImplicitMeta
      Rule: "ANY Writers"
    Admins:
      Type: ImplicitMeta
      Rule: "MAJORITY Admins"
    # BlockValidation specifies what signatures must be included in the block
    # from the orderer for the peer to validate it.
    BlockValidation:
      Type: ImplicitMeta
      Rule: "ANY Writers"

################################################################################
#
#   CHANNEL
#
#   This section defines the values to encode into a config transaction or
#   genesis block for channel related parameters.
#
################################################################################
Channel: &ChannelDefaults
  # Policies defines the set of policies at this level of the config tree
  # For Channel policies, their canonical path is
  #   /Channel/<PolicyName>
  Policies:
    # Who may invoke the 'Deliver' API
    Readers:
      Type: ImplicitMeta
      Rule: "ANY Readers"
    # Who may invoke the 'Broadcast' API
    Writers:
      Type: ImplicitMeta
      Rule: "ANY Writers"
    # By default, who may modify elements at this config level
    Admins:
      Type: ImplicitMeta
      Rule: "MAJORITY Admins"

  # Capabilities describes the channel level capabilities, see the
  # dedicated Capabilities section elsewhere in this file for a full
  # description
  Capabilities:
    <<: *ChannelCapabilities

################################################################################
#
#   Profile
#
#   - Different configuration profiles may be encoded here to be specified
#   as parameters to the configtxgen tool
#
################################################################################
Profiles:

  # test network profile with application (not system) channel.
  TwoOrgsApplicationGenesis:
    <<: *ChannelDefaults
    Orderer:
      <<: *OrdererDefaults
      Organizations:
        - *OrdererOrg
      Capabilities: *OrdererCapabilities
    Application:
      <<: *ApplicationDefaults
      Organizations:
        - *Org1
        - *Org2
      Capabilities: *ApplicationCapabilities


  #
  # Unclear lineage for these profiles:  nano-fab?
  #
  # TwoOrgsOrdererGenesis will construct a system channel as it has a Consortiums stanza, which is not
  # compatible with osnadmin.
  #
  # @enyeart - which profile should be used for the kube test network?
  #
  TwoOrgsOrdererGenesis:
    <<: *ChannelDefaults
    Orderer:
      <<: *OrdererDefaults
      OrdererType: etcdraft
      Organizations:
        - *OrdererOrg
      Capabilities:
        <<: *OrdererCapabilities
    Consortiums:
      SampleConsortium:
        Organizations:
          - *Org1
          - *Org2
  TwoOrgsChannel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
      <<: *ApplicationDefaults
      Organizations:
        - *Org1
        - *Org2
      Capabilities:
        <<: *ApplicationCapabilities
  Org1Channel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
      <<: *ApplicationDefaults
      Organizations:
        - *Org1
      Capabilities:
        <<: *ApplicationCapabilities
  Org2Channel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
      <<: *ApplicationDefaults
      Organizations:
        - *Org2
      Capabilities:
        <<: *ApplicationCapabilities
{{- end }}