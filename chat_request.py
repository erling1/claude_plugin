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

    def read_input(self):
        user_input = sys.stdin.read().strip()
        print(f"User Input is read: {user_input}", flush=True)
        messages = [
            {"role": "user", "content": user_input}
        ]
        return messages

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
