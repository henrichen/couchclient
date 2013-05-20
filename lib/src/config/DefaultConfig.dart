//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 05, 2013  06:50:16 PM
// Author: hernichen

part of couchclient;

class DefaultConfig implements Config {
  final HashAlgorithm hashAlgorithm;

  final int vbucketsCount;

  final int mask;

  final int serversCount;

  final int replicasCount;

  final List<String> servers;

  final List<Vbucket> vbuckets;

  final List<Uri> couchServers;

  final ConfigType configType;

  DefaultConfig(this.hashAlgorithm, this.serversCount, this.replicasCount,
      int vbucketsCount, this.servers, this.vbuckets,  this.couchServers)
      : this.vbucketsCount = vbucketsCount,
        mask = vbucketsCount - 1,
        configType = ConfigType.COUCHBASE;

  String getServer(int serverIndex)
  => servers[serverIndex];

  //Vbucket access
  int getVbucketByKey(String key) => mask & hashAlgorithm(key);

  int getMaster(int vbucketIndex)
  => vbuckets[vbucketIndex].master;

  int getReplica(int vbucketIndex, int replicaIndex)
  => vbuckets[vbucketIndex].replicas[replicaIndex];

  int foundIncorrectMaster(int vbucketIndex, int wrongServer) {
    int mappedServer = vbuckets[vbucketIndex].master;
    int rv = mappedServer;
    if (mappedServer == wrongServer) {
      rv = (rv + 1) % serversCount;
      vbuckets[vbucketIndex].master = rv;
    }
    return rv;
  }

  ConfigDifference compareTo(Config config) {
    ConfigDifference diff = new ConfigDifference();

    if (this.serversCount == config.serversCount) {
      diff.sequenceChanged = false;
      for (int j = 0; j < serversCount; ++j) {
        if (servers[j] != config.servers[j]) {
          diff.sequenceChanged = true;
          break;
        }
      }
    } else {
      diff.sequenceChanged = true;
    }

    if (ConfigType.COUCHBASE == config.configType
        && vbucketsCount == config.vbucketsCount) {
      int vbucketsChanges = 0;
      for (int j = 0; j < vbucketsCount; ++j)
        vbucketsChanges += getMaster(j) == config.getMaster(j) ? 0 : 1;
      diff.vbucketsChanges = vbucketsChanges;
    } else {
      diff.vbucketsChanges = -1;
    }

    return diff;
  }

  @override
  int get hashCode {
    int h = hashAlgorithm.hashCode;
    h = 31 * h + mask;
    h = 31 * h + replicasCount;
    h = 31 * h + listHashCode(servers);
    h = 31 * h + listHashCode(vbuckets);
    h = 31 * h + listHashCode(couchServers);
    h = 31 * h + configType.ordinal;
    return h & 0xffffffff;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Config) return false;
    return this.hashAlgorithm == other.hashAlgorithm
        && this.mask == other.mask
        && this.replicasCount == other.replicasCount
        && listEquals(this.servers, other.servers)
        && listEquals(this.vbuckets, other.vbuckets)
        && listEquals(this.couchServers, other.couchServers)
        && this.configType == other.configType;
  }
}
