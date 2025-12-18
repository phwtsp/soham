
import React, { useState, useEffect } from 'react';
import { HashRouter, Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import Dashboard from './screens/Dashboard';
import Login from './screens/Login';
import Premium from './screens/Premium';
import PatternsList from './screens/PatternsList';
import CreateBreathing from './screens/CreateBreathing';
import Player from './screens/Player';
import Finished from './screens/Finished';
import Settings from './screens/Settings';

const App: React.FC = () => {
  return (
    <HashRouter>
      <div className="flex justify-center bg-gray-100 min-h-screen">
        <div className="w-full max-w-md bg-white shadow-2xl relative min-h-screen flex flex-col">
          <Routes>
            <Route path="/" element={<Login />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/premium" element={<Premium />} />
            <Route path="/patterns" element={<PatternsList />} />
            <Route path="/create" element={<CreateBreathing />} />
            <Route path="/player" element={<Player />} />
            <Route path="/finished" element={<Finished />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </div>
      </div>
    </HashRouter>
  );
};

export default App;
