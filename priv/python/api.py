from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom

message_handler = None #reference to the elixir process to send result to

def message(message):
    message = message.decode("utf-8") 
    print('Hey, python has gotten the message: ' + message)
    return 'test'

def cast_message(pid, message):
    cast(pid, message)

def register_handler(pid):
    #save message handler pid
    global message_handler
    message_handler = pid

def handle_message(message):
    message = message.decode("utf-8")
    print("Received message from Elixir: " + message) 


set_message_handler(handle_message) #set handle_message to receive all messages sent to this python instance