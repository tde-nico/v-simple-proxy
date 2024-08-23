module main

import net

const shost = "0.0.0.0"
const sport = "8080"
const dhost = "127.0.0.1"
const dport = "8081"

fn transfer_data(mut sender net.TcpConn, mut reciver net.TcpConn) {
	mut buf := []u8{len: 1024}
	for {
		recived := sender.read(mut &buf) or { break }
		println(buf)
		sent := reciver.write(buf[0..recived]) or { break }
		if sent != recived {
			println("Data loss detected")
		}
	}
}

fn handle(mut client net.TcpConn) {
	addr := client.peer_addr() or { println("addr fetch error: ${err}"); return }
	defer { client.close() or { println("connection close error: ${err}") }; println("Client ${addr} Disconnected") }
	println("Client ${addr} Connected")

	mut server := net.dial_tcp(dhost + ":" + dport) or { println("dial error: ${err}"); return }
	defer { server.close() or { println("connection close error: ${err}") } }

	go transfer_data(mut client, mut server)
	transfer_data(mut server, mut client)
}

fn main() {
	saddr := shost + ":" + sport
	mut ln := net.listen_tcp(net.AddrFamily.ip, saddr, net.ListenOptions{}) or { panic(err) }
	println("Listening on ${saddr}")
	for {
		mut conn := ln.accept() or { panic(err) }
		go handle(mut conn)
	}
}
