from google import genai
from google.genai import errors
import os
import time

# 1. ናትካ API Key ኣብዚ የእቱ
API_KEY = "YOUR_API_KEY_HERE" 
client = genai.Client(api_key=API_KEY)

project_path = './lib' 
output_file = 'PROJECT_SUMMARY.md'

def analyze_flutter_project():
    print("ስራሕ ጀሚረ ኣለኹ (ብሞዴል Gemini 1.5 Flash)... በጃኻ ተጸበ።")
    with open(output_file, 'w', encoding='utf-8') as out:
        out.write("# ናይ ፍላተር ፕሮጀክት ጽማቐ (Project Summary)\n\n")
        
        # ኩሎም ፋይላት በብሓደ ንምንባብ
        for root, dirs, files in os.walk(project_path):
            for file in files:
                if file.endswith(".dart"):
                    file_path = os.path.join(root, file)
                    print(f"እናረኣኹዎ ዘለኹ ፋይል: {file}")
                    
                    with open(file_path, 'r', encoding='utf-8') as f:
                        code = f.read()
                        prompt = f"Explain what this Flutter file does in 2 short points in Tigrinya: \n\n {code}"
                        
                        success = False
                        retries = 0
                        while not success and retries < 3:
                            try:
                                # ኣብዚ 'gemini-1.5-flash' ንጥቀም ኣለና
                                response = client.models.generate_content(
                                    model='gemini-1.5-flash', 
                                    contents=prompt
                                )
                                out.write(f"### {file}\n")
                                out.write(f"{response.text}\n\n")
                                success = True
                                # ገደብ ንከይሓልፍ 10 ሰከንድ ዕረፍቲ (ንደቂቕ 6 ፋይላት ጥራይ)
                                time.sleep(10) 
                            except Exception as e:
                                if "429" in str(e):
                                    print(f"ገደብ በጺሑ ኣሎ፡ ን 20 ሰከንድ ክጽበ እየ ({file})...")
                                    time.sleep(20)
                                    retries += 1
                                else:
                                    print(f"Error in {file}: {e}")
                                    break

    print(f"ተወዲኡ! ነቲ '{output_file}' ዝብል ፋይል ርኣዮ።")

if __name__ == "__main__":
    analyze_flutter_project()