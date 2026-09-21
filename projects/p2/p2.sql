-- standalone script

DROP MATERIALIZED VIEW IF EXISTS ExamesColesterol CASCADE;
DROP MATERIALIZED VIEW IF EXISTS ExamesColesterolDiff;

CREATE MATERIALIZED VIEW ExamesColesterol AS (
    SELECT P.id_paciente, E.dt_coleta, E.id_atendimento,
        MAX(D.de_desfecho) AS Desfecho, -- fiz essa
        MAX(E.de_hospital) AS Hospital,
        MIN(D.dt_desfecho) - E.dt_coleta AS "Dias até desfecho", -- fiz essa
        ROW_NUMBER() OVER (PARTITION BY P.id_paciente ORDER BY E.dt_coleta) "N° do exame de colesterol do paciente", -- fiz essa
        ROW_NUMBER() OVER (PARTITION BY P.id_paciente, E.id_atendimento ORDER BY E.dt_coleta) "N° do exame de colesterol do atendimento", -- fiz essa
        AVG(REPLACE(E.de_resultado, ',', '.')::FLOAT) FILTER(WHERE E.de_analito ~*'ldl' AND E.de_analito!~*'vldl') AS LDL,
        AVG(REPLACE(E.de_resultado, ',', '.')::FLOAT) FILTER(WHERE E.de_analito ~*'hdl') AS HDL,
        AVG(REPLACE(E.de_resultado, ',', '.')::FLOAT) FILTER(WHERE E.de_analito ~*'v.*coles')AS VLDL,
        AVG(REPLACE(E.de_resultado, ',', '.')::FLOAT) FILTER(WHERE E.de_analito ~*'n[aã]o.hdl')AS NaoHDL,
        AVG(REPLACE(E.de_resultado, ',', '.')::FLOAT) FILTER(WHERE Lower(E.de_analito) IN ('colesterol total', 'colesterol')) AS Total,
        MAX(E.cd_unidade) AS Unidade
    FROM D2.ExamLabs E
        JOIN D2.Pacientes P on E.id_paciente = P.ID_Paciente
        JOIN D2.desfechos D on E.id_atendimento = D.ID_Atendimento -- fiz essa
    WHERE
        E.de_exame ~*'coleste' AND
        E.de_resultado!~'[^\d.,+-]'
--             AND P.CD_Municipio IN('GUARULHOS', 'OSASCO')
    GROUP BY P.id_paciente, E.id_atendimento, E.dt_coleta
    ORDER BY P.id_paciente, E.id_atendimento, E.dt_coleta
);

CREATE MATERIALIZED VIEW ExamesColesterolDiff AS (
    SELECT
        *,
        LDL - LAG(LDL) OVER(PARTITION BY id_paciente ORDER BY dt_coleta) LDL_diff,
        HDL - LAG(HDL) OVER(PARTITION BY id_paciente ORDER BY dt_coleta) HDL_diff,
        VLDL - LAG(VLDL) OVER(PARTITION BY id_paciente ORDER BY dt_coleta) VLDL_diff,
        NaoHDL - LAG(NaoHDL) OVER(PARTITION BY id_paciente ORDER BY dt_coleta) NaoHDL_diff,
        Total - LAG(Total) OVER(PARTITION BY id_paciente ORDER BY dt_coleta) Total_diff
    FROM ExamesColesterol
);

SELECT * FROM ExamesColesterolDiff
ORDER BY COUNT(*) OVER(PARTITION BY id_paciente) DESC, id_paciente, dt_coleta
;