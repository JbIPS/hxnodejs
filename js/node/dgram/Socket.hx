package js.node.dgram;

import js.node.events.EventEmitter;

/**
	Enumeration of events for the `Socket` object.
**/
@:enum abstract SocketEvent(String) to String {
	/**
		Emitted when a new datagram is available on a socket.
		Listener arguments:
			* msg:Buffer - received data
			* rinfo:RemoteInfo - sender's address information and the number of bytes in the datagram
	**/
	var Message = "message";

	/**
		Emitted when a socket starts listening for datagrams.
		This happens as soon as UDP sockets are created.
	**/
	var Listening = "listening";

	/**
		Emitted when a socket is closed with `close`.
		No new message events will be emitted on this socket.
	**/
	var Close = "close";

	/**
		Emitted when an error occurs.
		Listener arguments:
			* exception - error object
	**/
	var Error = "error";
}

/**
	Information about socket address.
**/
typedef AddressInfo = {
    var address:String;
    var family:String;
    var port:Int;
}

/**
    A structure passed to the callback of the 'message' event.
**/
typedef RemoteInfo = {
	>AddressInfo,
    var size:Int;
}

/**
    Enumeration of possible datagram socket types
**/
@:enum abstract SocketType(String) from String to String {
    var UDPv4 = "udp4";
    var UDPv6 = "udp6";
}

/**
	Encapsulates the datagram functionality. It should be created via `Dgram.createSocket`.
**/
extern class Socket extends EventEmitter<Socket> {
	/**
		The destination `port` and `address` must be specified.
		A string may be supplied for the `address` parameter, and it will be resolved with DNS.

		If the `address` is omitted or is an empty string, '0.0.0.0' or '::0' is used instead.
		Depending on the network configuration, those defaults may or may not work; it's best to be
		explicit about the destination address.

		If the socket has not been previously bound with a call to `bind`, it gets assigned a random
		port number and is bound to the "all interfaces" address ('0.0.0.0' for udp4 sockets, '::0' for udp6 sockets.)

		An optional `callback` may be specified to detect DNS errors or for determining when it's safe
		to reuse the buf object. Note that DNS lookups delay the time to send for at least one tick.
		The only way to know for sure that the datagram has been sent is by using a `callback`.
	**/
	@:overload(function(buf:Buffer, offset:Int, length:Int, port:Int, ?callback:Error->Int->Void):Void {})
	function send(buf:Buffer, offset:Int, length:Int, port:Int, address:String, ?callback:Error->Int->Void):Void;

	/**
		Listen for datagrams on a named `port` and optional `address`.
		If `address` is not specified, the OS will try to listen on all addresses.
		After binding is done, a "listening" event is emitted and the `callback` (if specified) is called.
		Specifying both a "listening" event listener and `callback` is not harmful but not very useful.

		A bound datagram socket keeps the node process running to receive datagrams.

		If binding fails, an "error" event is generated. In rare case (e.g. binding a closed socket),
		an `Error` may be thrown by this method.
	**/
	@:overload(function(port:Int, address:String, ?callback:Void->Void):Void {})
	function bind(port:Int, ?callback:Void->Void):Void;

	/**
		Close the underlying socket and stop listening for data on it.
	**/
	function close():Void;

	/**
		Returns an object containing the address information for a socket.
	**/
	function address():AddressInfo;

	/**
		Sets or clears the SO_BROADCAST socket option.
		When this option is set, UDP packets may be sent to a local interface's broadcast address.
	**/
	function setBroadcast(flag:Bool):Void;

	/**
		Sets the IP_TTL socket option. TTL stands for "Time to Live," but in this context it specifies
		the number of IP hops that a packet is allowed to go through. Each router or gateway that forwards
		a packet decrements the TTL. If the TTL is decremented to 0 by a router, it will not be forwarded.
		Changing TTL values is typically done for network probes or when multicasting.

		The argument to `setTTL` is a number of hops between 1 and 255. The default on most systems is 64.
	**/
	function setTTL(ttl:Int):Void;

	/**
		Sets the IP_MULTICAST_TTL socket option. TTL stands for "Time to Live," but in this context it specifies
		the number of IP hops that a packet is allowed to go through, specifically for multicast traffic.
		Each router or gateway that forwards a packet decrements the TTL. If the TTL is decremented to 0 by a router,
		it will not be forwarded.

		The argument to `setMulticastTTL` is a number of hops between 0 and 255. The default on most systems is 1.
	**/
	function setMulticastTTL(ttl:Int):Void;

	/**
		Sets or clears the IP_MULTICAST_LOOP socket option.
		When this option is set, multicast packets will also be received on the local interface.
	**/
	function setMulticastLoopback(flag:Bool):Void;

	/**
		Tells the kernel to join a multicast group with IP_ADD_MEMBERSHIP socket option.

		If `multicastInterface` is not specified, the OS will try to add membership to all valid interfaces.
	**/
	function addMembership(multicastAddress:String, ?multicastInterface:String):Void;

	/**
		Opposite of `addMembership` - tells the kernel to leave a multicast group with IP_DROP_MEMBERSHIP socket option.
		This is automatically called by the kernel when the socket is closed or process terminates,
		so most apps will never need to call this.

		If `multicastInterface` is not specified, the OS will try to drop membership to all valid interfaces.
	**/
	function dropMembership(multicastAddress:String, ?multicastInterface:String):Void;

	/**
		Calling `unref` on a socket will allow the program to exit if this is the only active socket in the event system.
		If the socket is already `unref`d calling `unref` again will have no effect.
	**/
	function unref():Void;

	/**
		Opposite of `unref`, calling `ref` on a previously `unref`d socket will not let
		the program exit if it's the only socket left (the default behavior).
		If the socket is `ref`d calling `ref` again will have no effect.
	**/
	function ref():Void;
}
