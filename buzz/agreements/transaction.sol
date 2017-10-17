pragma solidity ^0.4.17;

        contract transaction {
            bool complete; //replace with state transitions
            address guest;
            address host;
            address arbiter; //sent to this address if bad transaction
            uint rentValue;
            uint completeTime;
            bool hostSatisfied = false;
            bool guestSatisfied = false;
            uint expTime;
            bytes32 rentId;

            event contractIsComplete(uint timestamp);
            event contractStart(uint timestamp, bytes32 rentId);
            event contractEnded(uint timestamp, bytes32 rendId);

            modifier guestHostOnly() {
                if(msg.sender != guest || msg.sender != host)
                    revert();
                else _;
            }

            modifier notExpired() {
                if(block.timestamp >= expTime) {
                    fallback(); //send funds to arbiter
                    revert();
                }
                else _;

            }

            function() { revert(); }//return funds minus gased used if wrongly sent

            function transaction(address specifiedHost, address specifiedGuest, bytes32 rentTitle, uint expiry) {
                host = specifiedHost;
                guest = specifiedGuest;
                arbiter = msg.sender;
                contractStart(block.timetamp, rentTitle);
                expTime = block.timestamp + expiry;
                rentId = rentTitle;
            }

            function payContract() payable {
                if(msg.sender != guest || complete) revert();
                rentValue = msg.value;
                complete = true;
                completeTime = block.timestamp;
                contractIsComplete(completeTime);
            }

            function satisfied() guestHostOnly notExpired {
                if(msg.sender == host) {
                    hostSatisfied = true;
                }
                else {
                    guestSatisfied = true;
                }
                if(guestSatisfied && hostSatisfied) {
                    payout();
                }
            }

            function payout() internal {
                contractEnded(block.timestamp, rentId);
                selfdestruct(host); //sends money to host
            }

            function fallback() internal {
                contractEnded(block.timestamp, rentId);
                selfdestruct(arbiter);
            }

        }


