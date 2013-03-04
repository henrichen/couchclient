part of rikulo_memcached;

/**
 * State of this operation.
 */
class OPState extends Enum {
  /**
   * State indicating this operation is waiting to be written to the server.
   */
  static const OPState WRITE_QUEUED = const OPState(0);
  /**
   * State indicating this operation is writing data to the server.
   */
  static const OPState WRITING = const OPState(1);
  /**
   * State indicating this operation is reading data from the server.
   */
  static const OPState READING = const OPState(2);
  /**
   * State indicating this operation is complete.
   */
  static const OPState COMPLETE = const OPState(3);
  /**
   * State indicating this operation needs to be resent.  Typically
   * this means vbucket hashing and there is a topology change.
   */
  static const OPState RETRY = const OPState(4);

  const OPState(int ordinal)
      : super(ordinal);
}

