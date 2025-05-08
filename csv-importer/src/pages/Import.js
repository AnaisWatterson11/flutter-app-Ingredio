import React, { useState } from 'react';
import CSVReader from 'react-csv-reader';
import { collection, doc, writeBatch, addDoc } from "firebase/firestore";
import { db } from "../firebase";

export default function Import() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const batch = writeBatch(db);

  const papaparseOptions = {
    // Add any PapaParse options if needed
    header: true,
    skipEmptyLines: true
  };

  function iterate_data(sdata, fileInfo, originalFile) {
    setData(sdata);
  }

  async function import_into_firebase() {
    setLoading(true);
    try {
      const docRef = collection(db, 'recipes_mode');

      data.map((item, index) => {
        console.log(item);
        addDoc(docRef, item);
      });

      // If you plan to use batches instead:
      // await batch.commit();

      setLoading(false);
      return docRef;
      
    } catch (error) {
      console.log(error);
      setLoading(true);
    }
  }

  return (
    <>
      <h1 className="ml-12 mt-12 text-3xl">CSV Importer for Firebase</h1>

      <div className="bg-blue-300 ml-12 mt-12 p-12">
        <CSVReader
          onFileLoaded={iterate_data}
          parserOptions={papaparseOptions}
        />
      </div>

      <button
        onClick={()=>import_into_firebase()}
        className="bg-green-600 rounded-md ml-12 mt-4 p-4 text-white">
      
        {loading ? "loading..." : "Import to Firebase"}
      </button>

      <div className="bg-yellow-300 ml-12 mt-4 p-12 text-black">
        {/* Optional: Debug output */}
        {/* <pre>{JSON.stringify(data, null, 2)}</pre> */}

        <table className="ml-12 mt-4 p-4 text-black">
          {data.map((item, index) => (
            <tr key={index}>
              <td>{item.city}</td>
              <td className="ml-2">{item.state}</td>
              <td className="ml-2">{item.country}</td>
            </tr>
          ))}
        </table>
      </div>
    </>
  );
}
