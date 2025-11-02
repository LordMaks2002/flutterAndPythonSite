# main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import uuid
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TodoCreate(BaseModel):
    title: str

class TodoUpdate(BaseModel):
    completed: bool

class Todo(BaseModel):
    id: str
    title: str
    completed: bool = False
    updatedAt: str

todos: List[Todo] = []

@app.get("/todos", response_model=List[Todo])
def get_todos():
    return todos

@app.post("/todos", response_model=Todo, status_code=201)
def create_todo(todo: TodoCreate):
    new_todo = Todo(
        id=str(uuid.uuid4()),
        title=todo.title,
        updatedAt=datetime.utcnow().isoformat()
    )
    todos.append(new_todo)
    return new_todo

@app.put("/todos/{todo_id}", response_model=Todo)
def update_todo(todo_id: str, update: TodoUpdate):
    for todo in todos:
        if todo.id == todo_id:
            todo.completed = update.completed
            todo.updatedAt = datetime.utcnow().isoformat()
            return todo
    raise HTTPException(404, "Not found")

@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: str):
    global todos
    todos = [t for t in todos if t.id != todo_id]
    return {"message": "Deleted"}