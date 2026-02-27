-- ==============================================================================
-- Esquema de Base de Datos para AntLogger - Registro de Colonia y Eventos
-- ==============================================================================
-- Este script crea las tablas necesarias en Supabase (PostgreSQL) para almacenar
-- la información estructurada de tu archivo AntLogger_Consolidado_v1.3.md
-- y permitir el cruce temporal con tus datos de sensores (temperatura, humedad, presión).

-- ------------------------------------------------------------------------------
-- 1. Tabla: colony_phases (Fases Evolutivas)
-- Representa los grandes periodos (Fase 1, Fase 2...) definidos en tu documento.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.colony_phases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    
    -- Identificador del dispositivo/colonia (para múltiples hormigueros)
    -- Se recomienda usar el mismo UUID que usas en tu firmware (DEVICE_UUID)
    device_id UUID NOT NULL, 
    
    name TEXT NOT NULL,          -- Ej: "Fase 1 - Inicio frío y ajustes hídricos"
    description TEXT,            -- Descripción general de la fase
    
    start_date TIMESTAMPTZ NOT NULL, -- Fecha inicio de la fase
    end_date TIMESTAMPTZ,            -- Fecha fin (NULL si es la fase actual)
    
    is_active BOOLEAN DEFAULT false  -- Flag para identificar fase actual rápidamente
);

-- Comentarios para documentación en Supabase
COMMENT ON TABLE public.colony_phases IS 'Periodos evolutivos principales de la colonia (Fase 1, Fase 2, etc.)';

-- ------------------------------------------------------------------------------
-- 2. Tabla: colony_events (Eventos y Observaciones)
-- Desglose diario de eventos (Ej: "Mortalidad aislada", "Excavación masiva").
-- Se vincula a una fase y tiene timestamp preciso para cruzar con sensores.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.colony_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    
    phase_id UUID REFERENCES public.colony_phases(id) ON DELETE SET NULL,
    device_id UUID NOT NULL, -- Redundancia útil para queries rápidas por dispositivo
    
    event_type TEXT NOT NULL CHECK (event_type IN ('MORTALITY', 'EXCAVATION', 'FORAGING', 'MAINTENANCE', 'OBSERVATION', 'OTHER')),
    description TEXT NOT NULL,   -- Detalle: "Extracción de terrones compactos"
    
    observed_at TIMESTAMPTZ NOT NULL DEFAULT now(), -- Momento exacto del evento
    
    intensity INTEGER CHECK (intensity BETWEEN 1 AND 5), -- Escala 1-5 (opcional) para graficar picos
    tags TEXT[] -- Array de etiquetas: ['moho', 'humedad', 'nocturno']
);

COMMENT ON TABLE public.colony_events IS 'Registro detallado de eventos y comportamientos diarios';

-- ------------------------------------------------------------------------------
-- 3. Tabla: colony_indicators (Indicadores Técnicos / Snapshot)
-- Estado del hormiguero en momentos puntuales (Ej: Resumen a 27/02).
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.colony_indicators (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recorded_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    device_id UUID NOT NULL,
    
    mortality_count INTEGER DEFAULT 0,      -- Mortalidad acumulada o del periodo
    mold_status TEXT DEFAULT 'NONE' CHECK (mold_status IN ('NONE', 'DETECTED', 'RESOLVED', 'CRITICAL')),
    water_system_status TEXT DEFAULT 'STABLE' CHECK (water_system_status IN ('STABLE', 'LOW', 'EMPTY', 'LEAK')),
    risk_level TEXT DEFAULT 'LOW' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    
    notes TEXT -- Notas adicionales sobre el estado (Ej: "Moho resuelto tras intervención")
);

COMMENT ON TABLE public.colony_indicators IS 'Snapshots periódicos del estado técnico de la colonia';

-- ------------------------------------------------------------------------------
-- 4. Políticas de Seguridad (RLS - Row Level Security)
-- Habilitamos RLS pero permitimos acceso público para lectura/escritura por defecto
-- (Ajustar según tus necesidades de Auth en Supabase)
-- ------------------------------------------------------------------------------

-- Habilitar RLS en las tablas
ALTER TABLE public.colony_phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.colony_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.colony_indicators ENABLE ROW LEVEL SECURITY;

-- Política permisiva (para empezar): Permitir todo a usuarios anonimos/autenticados con la key correcta
-- IMPORTANTE: En producción, restringir esto a usuarios autenticados si es necesario.
CREATE POLICY "Enable all access for anon and authenticated users" ON public.colony_phases
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for anon and authenticated users" ON public.colony_events
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for anon and authenticated users" ON public.colony_indicators
    FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- DATOS DE EJEMPLO (Basados en tu MD v1.3)
-- Descomenta y ejecuta si quieres poblar la base con tus datos iniciales
-- ==============================================================================

/*
-- Insertar Fase 1
INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date)
VALUES 
('8e7f86c2-1c0b-4d2e-9b76-1c5b0c6f1a23', 'Fase 1 - Inicio frío y ajustes hídricos', 'Baja actividad, problemas iniciales de humedad.', '2026-02-01 00:00:00+00', '2026-02-10 23:59:59+00');

-- Insertar Fase 2
INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date)
VALUES 
('8e7f86c2-1c0b-4d2e-9b76-1c5b0c6f1a23', 'Fase 2 - Transición estructural', 'Nuevo forrajeo seco, uso de tubo como vertedero.', '2026-02-11 00:00:00+00', '2026-02-21 23:59:59+00');

-- Insertar Evento de Ejemplo (Fase 4 - Ventanas nocturnas)
INSERT INTO public.colony_events (device_id, event_type, description, observed_at, tags)
VALUES 
('8e7f86c2-1c0b-4d2e-9b76-1c5b0c6f1a23', 'EXCAVATION', 'Ventanas nocturnas recurrentes (21:30--22:40)', '2026-02-24 21:30:00+00', ARRAY['nocturno', 'excavacion']);
*/
