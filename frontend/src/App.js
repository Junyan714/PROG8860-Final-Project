import React, { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetch('http://127.0.0.1:5000/api/greeting') 
      .then(response => response.json())
      .then(data => {
        console.log('Fetched message:', data.message); // 查看数据
        setMessage(data.message);
      })
      .catch(err => console.error('Error fetching greeting:', err));
  }, []);

  return (
    <div>
      <h1>{message || "Loading..."}</h1>
    </div>
  );
}

export default App;
