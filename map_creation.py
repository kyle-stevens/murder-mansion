import random

#for i in range(0,100):
#	print(random.randint(0,10))

seed = int(input("What Seed would you like to use for generation? (0 for no seed) "))
random.seed(a=seed)


player_type = input("Are you a killer(k) or a victim(v)? ")



possible_rooms = [
	"Kitchen",
	"Greenhouse",
	"Library",
	"Den",
	"Trophy Room",
	"Armory",
	"Basement", #Special room only on first floor
	"Attic", #Special room only on second floor
	"Master Bedroom",
	"Dining Room",
	"Gallery",
	"Bedroom",
	"Storage Room"

]


num_of_rooms = int(input("How Many Rooms (maximum of 13)? "))
num_of_passages = int(input("How Many Passages? "))


room_nums = []
for i in range(0, num_of_rooms):
	new_room = random.randint(0,len(possible_rooms)-1)
	while new_room in room_nums:
		new_room = random.randint(0,len(possible_rooms)-1)
	room_nums.append(new_room)

#print(room_nums)

passage_pairs = [] #thruple, rooms that are connected and if they are two way
for j in range(0, num_of_passages):
	new_passage = ( random.randint( 0,len(room_nums)-1 ), random.randint(0,len(room_nums)-1 ), random.randint(0,100) % 2==0 ) #50% chance for two way passage
	while new_passage[0] == new_passage[1] or new_passage in passage_pairs or (new_passage[1], new_passage[0]) in passage_pairs:
		new_passage = ( random.randint( 0,len(room_nums)-1 ), random.randint( 0,len(room_nums)-1 ), random.randint(0,100) % 2==0 )
	passage_pairs.append( (room_nums[new_passage[0]], room_nums[new_passage[1]], new_passage[2]) )

#print(passage_pairs)

print("\n\nMansion consists of these rooms")
for room in room_nums:
	print("\tA", possible_rooms[room])


if player_type == "k":
	print("With Secret Passages connecting")
	for passage in passage_pairs:
		#print(type(passage[2]))
		if passage[2]:
			print("\tThe", possible_rooms[passage[0]], "with the", possible_rooms[passage[1]], "(two-way passage)")
		else:
			print("\tThe", possible_rooms[passage[0]], "to the", possible_rooms[passage[1]])


print("\n\nAll Rooms are connected via hallways to the main foyer which also contains the grand staircase that bridges the first and second floor")
print("The Secret Passages are known to the killers, but may be discovered by the victims")
