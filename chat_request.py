import sys
import os
from openai import OpenAI

class ChatClient:
    def __init__(self, model="gpt-4", temperature=1.0):
        self.api_key = os.environ.get("OPENAI_API_KEY")

        if not self.api_key:
            raise ValueError("Missing OPENAI_API_KEY environment variable")
        
        self.client = OpenAI(api_key=self.api_key)
        self.model = model
        self.temperature = temperature
        self.all_files = None

    async def read_input(self):
        user_input = sys.stdin.read().strip()
        print(f"User Input is read: {user_input}", flush=True)
        messages = [
            {"role": "user", "content": user_input}
        ]

        if not self.all_files:
            self.all_files = await self.read_file_tree()

            messages.append({"role": "user", "content": "Below is a dictionary showing the entire file content of the users files, which are important for you to read when you analyse the code and file structure. when making changes, you will be specifiying in which files you want to do changes" })
            messages.append({"role": "user", "content": str(self.all_files)})

        return messages


    async def read_file_tree(self):
        current_dir = sys.argv[1] if len(sys.argv) > 1 else "."
        contents = os.listdir(current_dir)

        all_files = {}

        if os.path.isfile(full_file_path):
            try:
                async with aiofiles.open(full_file_path, mode='r') as f:
                    file_contents = await f.read()
                all_files[file] = file_contents
            except Exception as e:
                print(f"Warning: Could not read {file}: {e}", flush=True)
        
        return all_files


    #def read_file_content(self):
    #    current_file = sys.argv[2]
    #    with open(current_file, 'r') as f:
    #        content = f.read()

     #   return content

        

    def make_api_call(self, messages):
        response = self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=self.temperature
        )
        return response.choices[0].message.content

    def run(self):
        messages = self.read_input()
        response = self.make_api_call(messages)
        print(response, flush=True)



if __name__ == "__main__":
    client = ChatClient()
    client.run()
